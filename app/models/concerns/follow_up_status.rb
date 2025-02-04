module FollowUpStatus
  extend ActiveSupport::Concern

  included do
    enum :status, {
      not_invited: "not_invited",
      invitation_pending: "invitation_pending",
      rdv_pending: "rdv_pending",
      rdv_needs_status_update: "rdv_needs_status_update",
      rdv_noshow: "rdv_noshow",
      rdv_revoked: "rdv_revoked",
      rdv_excused: "rdv_excused",
      rdv_seen: "rdv_seen",
      closed: "closed"
    }
    before_save :set_status
  end

  def set_status
    participations.reload
    invitations.reload
    self.status = compute_status
  end

  private

  def compute_status
    return :closed if closed_at.present?

    return :not_invited if invitations.empty? && rdvs.empty?

    invitation_sent_after_last_created_participation? ? :invitation_pending : status_from_participations
  end

  def invitation_sent_after_last_created_participation?
    return false if invitations.empty?
    return true if participations.empty?

    # If there is a pending rdv we compare to the date of the rdv, otherwise to the date of
    # the participation creation
    participation_date_to_compare =
      if last_created_participation.pending?
        last_created_participation.starts_at
      else
        last_created_participation.created_at
      end

    last_invitation_created_at > participation_date_to_compare
  end

  def seen_rdv_after_last_created_participation?
    seen_participations.present? &&
      seen_participations.max_by(&:starts_at).starts_at > last_created_participation.created_at
  end

  def status_from_participations
    if participations.any?(&:pending?)
      :rdv_pending
    elsif last_created_participation.seen? || seen_rdv_after_last_created_participation?
      :rdv_seen
    elsif last_created_participation.cancelled?
      :"rdv_#{last_created_participation.status}"
    else
      :rdv_needs_status_update
    end
  end
end
