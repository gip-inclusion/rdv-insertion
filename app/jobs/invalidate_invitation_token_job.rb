class InvalidateInvitationTokenJobError < StandardError; end

class InvalidateInvitationTokenJob < ApplicationJob
  def perform(invitation_id)
    invitation = Invitation.find(invitation_id)
    return if invitation.expired?

    invalidate_token = Invitations::InvalidateToken.call(invitation_id: invitation_id)

    raise InvalidateInvitationTokenJobError, invalidate_token.errors.join(" - ") unless invalidate_token.success?
  end
end
