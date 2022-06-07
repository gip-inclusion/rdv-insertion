module InvitableConcern
  extend ActiveSupport::Concern

  def first_sent_invitation
    invitations.select(&:sent_at).min_by(&:sent_at)
  end

  def first_invitation_sent_at
    first_sent_invitation&.sent_at
  end

  def first_sent_invitation_after_last_seen_rdv_sent_at
    invitations.select { |invitation| invitation.sent_at > last_seen_rdv.starts_at }.map(&:sent_at).compact.min
  end

  def last_sent_invitation
    invitations.select(&:sent_at).max_by(&:sent_at)
  end

  def last_invitation_sent_at
    last_sent_invitation&.sent_at
  end

  def last_sent_sms_invitation
    invitations.select { |invitation| invitation.format == "sms" }.select(&:sent_at).max_by(&:sent_at)
  end

  def last_sms_invitation_sent_at
    last_sent_sms_invitation&.sent_at
  end

  def last_sent_email_invitation
    invitations.select { |invitation| invitation.format == "email" }.select(&:sent_at).max_by(&:sent_at)
  end

  def last_email_invitation_sent_at
    last_sent_email_invitation&.sent_at
  end

  def last_postal_invitation
    invitations.select { |invitation| invitation.format == "postal" }.select(&:sent_at).max_by(&:sent_at)
  end

  def last_postal_invitation_sent_at
    last_postal_invitation&.sent_at
  end

  def invited_before_time_window?(number_of_days_before_action_required)
    invitation_date_to_compare = \
      if last_seen_rdv.present? && status != "rdv_seen"
        first_sent_invitation_after_last_seen_rdv_sent_at
      else
        first_invitation_sent_at
      end
    invitation_date_to_compare && invitation_date_to_compare < number_of_days_before_action_required.days.ago
  end
end
