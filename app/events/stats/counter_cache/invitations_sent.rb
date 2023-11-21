module Stats
  module CounterCache
    class InvitationsSent
      include EventSubscriber
      include Counter

      catch_events :create_invitation_successful, :update_invitation_successful

      def run_if(invitation)
        invitation.previous_changes[:sent_at].present? && invitation.sent_at.present?
      end

      def scopes
        invitation = Invitation.find_by(id: params["id"])
        [invitation.department, invitation.organisations.to_a].flatten.compact
      end
    end
  end
end
