module HasStatusConcern
  extend ActiveSupport::Concern

  included do
    before_save :set_status
  end

  def set_status
    return if status.in?(%w[deleted])

    rdvs.reload
    invitations.reload
    self.status = compute_status
  end

  private

  def compute_status
    rdvs.empty? ? status_without_rdv : status_with_rdv
  end

  def status_without_rdv
    invitation_sent? ? invitation_status : :not_invited
  end

  def invitation_sent?
    invitations.any?(&:sent_at)
  end

  def invitation_status
    invitation_accepted_at.present? ? :rdv_creation_pending : :invitation_pending
  end

  def status_with_rdv
    if seen_rdvs?
      :rdv_seen
    elsif multiple_cancelled_rdvs?
      :multiple_rdvs_cancelled
    elsif pending_rdvs?
      :rdv_pending
    elsif last_rdv_cancelled?
      :"rdv_#{rdvs.last.status}"
    else
      # this means there is a past rdv that is still in "pending" or "unknown"
      :rdv_needs_status_update
    end
  end

  def multiple_cancelled_rdvs?
    rdvs.cancelled_by_user.length > 1
  end

  def last_rdv_cancelled?
    rdvs.last.cancelled?
  end

  def seen_rdvs?
    rdvs.any?(&:seen?)
  end

  def pending_rdvs?
    rdvs.any?(&:pending?)
  end
end
