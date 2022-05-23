module HasStatusConcern
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

    invited_after_last_rdv? ? :invitation_pending : rdv_status
  end

  def last_rdv
    rdvs.last
  end

  def last_sent_invitation
    invitations.select(&:sent_at).last
  end

  def invited_after_last_rdv?
    return false unless invitation_sent?
    return true if rdvs.empty?

    # If there is a pending or a seen rdv we compare to the date of the rdv, otherwise to the date of
    # the rdv creation
    rdv_date_to_compare = \
      if last_rdv.pending? || last_rdv.seen?
        last_rdv.starts_at
      else
        last_rdv.created_at
      end
    last_sent_invitation.sent_at > rdv_date_to_compare
  end

  def invitation_sent?
    invitations.any?(&:sent_at)
  end

  def rdv_status
    if last_rdv.pending?
      :rdv_pending
    elsif last_rdv.seen?
      :rdv_seen
    elsif multiple_cancelled_rdvs?
      :multiple_rdvs_cancelled
    elsif last_rdv.cancelled?
      :"rdv_#{last_rdv.status}"
    else
      :rdv_needs_status_update
    end
  end

  def multiple_cancelled_rdvs?
    rdvs.cancelled_by_user.length > 1
  end
end
