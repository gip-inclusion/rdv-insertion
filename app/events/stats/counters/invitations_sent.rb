module Stats
  module Counters
    class InvitationsSent
      include Counter

      count every: [:create_invitation, :update_invitation],
            where: -> { invitation.previous_changes[:sent_at].present? && invitation.sent_at.present? },
            scopes: -> { [invitation.department, invitation.organisations.to_a] }
    end
  end
end
