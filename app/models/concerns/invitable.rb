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

  def currently_invited_by?(format)
    if participations.any?
      first_invitation_after_last_participation_by(format).present?
    else
      last_agent_initiated_invitation_by(format).present?
    end
  end

  def all_invitations_expired?
    invitations.all?(&:expired?)
  end

  def last_invitation_expires_at
    invitations.maximum(:expires_at)
  end

  def invalidate_invitations
    invitations.each do |invitation|
      ExpireInvitationJob.perform_later(invitation.id)
    end
  end

  def last_agent_initiated_invitation
    invitations.select(&:agent_initiated?).max_by(&:created_at)
  end

  def last_agent_initiated_invitation_by(format)
    invitations.select { |invitation| invitation.agent_initiated? && invitation.format == format }
               .max_by(&:created_at)
  end

  def in_cooldown_for?(format)
    return false if format == "postal"

    last_invitation = last_agent_initiated_invitation_by(format)
    last_invitation && last_invitation.created_at > 24.hours.ago
  end
end
