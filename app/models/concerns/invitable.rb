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

  def reference_invitation_for_current_period
    participations.any? ? first_invitation_after_last_participation : last_manual_invitation
  end

  def reference_invitation_for_current_period_by(format)
    participations.any? ? first_invitation_after_last_participation_by(format) : last_manual_invitation_by(format)
  end

  def all_invitations_expired?
    invitations.all?(&:expired?)
  end

  def invalidate_invitations
    invitations.each do |invitation|
      ExpireInvitationJob.perform_later(invitation.id)
    end
  end

  def last_manual_invitation
    invitations.manual.max_by(&:created_at)
  end

  def last_manual_invitation_by(format)
    invitations.manual.select { |invitation| invitation.format == format }.max_by(&:created_at)
  end
end
