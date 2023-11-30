module Stats
  module CounterCache
    class InvitationsSent
      include Counter

      catch_events :create_invitation_successful, :update_invitation_successful, if: lambda { |invitation|
        invitation.previous_changes[:sent_at].present? && invitation.sent_at.present?
      }

      def scopes
        [invitation.department, invitation.organisations.to_a].flatten.compact
      end
    end
  end
end
