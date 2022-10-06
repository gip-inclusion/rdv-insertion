module Invitable
  extend ActiveSupport::Concern

  def sent_invitations
    invitations.to_a.select(&:sent_at?)
  end

  def first_sent_invitation
    sent_invitations.min_by(&:sent_at)
  end

  def first_invitation_sent_at
    first_sent_invitation&.sent_at
  end

  def first_sent_invitation_after_last_seen_rdv
    sent_invitations.select { |invitation| invitation.sent_at > last_seen_rdv.starts_at }
                    .min_by(&:sent_at)
  end

  def first_sent_invitation_after_last_seen_rdv_sent_at
    first_sent_invitation_after_last_seen_rdv&.sent_at
  end

  def last_sent_invitation
    sent_invitations.max_by(&:sent_at)
  end

  def last_invitation_sent_at
    last_sent_invitation&.sent_at
  end

  def last_sent_sms_invitation
    sent_invitations.select { |invitation| invitation.format == "sms" }.max_by(&:sent_at)
  end

  def last_sms_invitation_sent_at
    last_sent_sms_invitation&.sent_at
  end

  def last_sent_email_invitation
    sent_invitations.select { |invitation| invitation.format == "email" }.max_by(&:sent_at)
  end

  def last_email_invitation_sent_at
    last_sent_email_invitation&.sent_at
  end

  def last_sent_postal_invitation
    sent_invitations.select { |invitation| invitation.format == "postal" }.max_by(&:sent_at)
  end

  def last_sent_postal_invitation_sent_at
    last_sent_postal_invitation&.sent_at
  end

  def invited_through?(format)
    sent_invitations.any? { |invitation| invitation.format == format }
  end

  def relevant_first_invitation
    last_seen_rdv.present? ? first_sent_invitation_after_last_seen_rdv : first_sent_invitation
  end

  def relevant_first_invitation_sent_at
    relevant_first_invitation&.sent_at
  end

  def invited_before_time_window?(number_of_days_before_action_required)
    relevant_first_invitation_sent_at &&
      relevant_first_invitation_sent_at < number_of_days_before_action_required.days.ago
  end
end
