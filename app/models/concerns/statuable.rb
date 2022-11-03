module Statuable
  extend ActiveSupport::Concern

  included do
    enum status: {
      not_invited: 0, invitation_pending: 1, rdv_pending: 2,
      rdv_needs_status_update: 3, rdv_noshow: 4, rdv_revoked: 5, rdv_excused: 6,
      rdv_seen: 7, multiple_rdvs_cancelled: 8
    }
    before_save :set_status
  end

  def set_status
    rdvs.reload
    invitations.reload
    self.status = compute_status
  end

  private

  def compute_status
    return :not_invited if !invitation_sent? && rdvs.empty?

    invited_after_last_created_rdv? ? :invitation_pending : rdv_status
  end

  def last_created_rdv
    rdvs.max_by(&:created_at)
  end

  def last_created_participation
    last_created_rdv.participations.find_by(applicant: applicant)
  end

  def last_sent_invitation
    invitations.max_by(&:sent_at)
  end

  def invited_after_last_created_rdv?
    return false unless invitation_sent?
    return true if rdvs.empty?

    # If there is a pending or a seen rdv we compare to the date of the rdv, otherwise to the date of
    # the rdv creation
    rdv_date_to_compare = \
      if last_created_participation.pending? \
        || last_created_participation.seen?
        last_created_rdv.starts_at
      else
        last_created_rdv.created_at
      end
    last_sent_invitation.sent_at > rdv_date_to_compare
  end

  def invitation_sent?
    invitations.any?(&:sent_at)
  end

  def rdv_status
    if participations.any?(&:pending?)
      :rdv_pending
    elsif last_created_participation.seen?
      :rdv_seen
    elsif multiple_cancelled_participations?
      :multiple_rdvs_cancelled
    elsif last_created_participation.cancelled?
      :"rdv_#{last_created_participation.status}"
    else
      :rdv_needs_status_update
    end
  end

  def multiple_cancelled_participations?
    participations.cancelled_by_user.length > 1
  end
end
