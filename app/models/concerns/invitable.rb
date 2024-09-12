module Invitable
  extend ActiveSupport::Concern

  def first_invitation
    invitations.min_by(&:created_at)
  end

  def first_invitation_created_at
    first_invitation&.created_at
  end

  def first_invitation_after_last_participation
    invitations.select { |invitation| invitation.created_at > last_created_participation.created_at }
               .min_by(&:created_at)
  end

  def first_invitation_after_last_participation_by(format)
    invitations.select do |invitation|
      invitation.format == format && invitation.created_at > last_created_participation.created_at
    end.min_by(&:created_at)
  end

  def last_invitation
    invitations.max_by(&:created_at)
  end

  def last_invitation_created_at
    last_invitation&.created_at
  end

  def first_invitation_by(format)
    invitations.select { |invitation| invitation.format == format }.min_by(&:created_at)
  end

  def invited_through?(format)
    invitations.any? { |invitation| invitation.format == format }
  end

  def first_invitation_relative_to_last_participation
    participations.any? ? first_invitation_after_last_participation : first_invitation
  end

  def first_invitation_relative_to_last_participation_by(format)
    participations.any? ? first_invitation_after_last_participation_by(format) : first_invitation_by(format)
  end

  def first_invitation_relative_to_last_participation_created_at
    first_invitation_relative_to_last_participation&.created_at
  end

  def first_invitation_relative_to_last_participation_created_at_by(format)
    first_invitation_relative_to_last_participation_by(format)&.created_at
  end

  def last_invitation_sent_manually
    invitations.reject { |invitation| invitation.trigger == "reminder" }
               .max_by(&:created_at)
  end

  def invited_before_time_window?(number_of_days_before_action_required)
    last_invitation_sent_manually.present? &&
      last_invitation_sent_manually.created_at < number_of_days_before_action_required.days.ago
  end

  def invalidate_invitations
    invitations.each do |invitation|
      InvalidateInvitationJob.perform_later(invitation.id)
    end
  end
end
