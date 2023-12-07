module Stats
  module Counters
    class InvitationsSent
      include Statisfy::Counter

      count every: [:invitation_created, :invitation_updated],
            if: -> { invitation.previous_changes[:sent_at].present? && invitation.sent_at.present? },
            scopes: -> { [invitation.department, invitation.organisations] }
    end
  end
end
