module Stats
  module CounterCache
    class DaysBetweenInvitationAndRdv
      include EventSubscriber
      include Counter

      catch_events :create_participation_successful

      def run_if(participation)
        participation.rdv_context.participations.size < 2 &&
          participation.rdv_context.invitations.present?
      end

      def scopes
        [@participation.department, @participation.organisation]
      end

      def process_event
        @participation = Participation.find_by(id: params["id"])
        offset = @participation.rdv_context.time_between_invitation_and_rdv_in_days

        append(value: offset)
      end

      def self.value(scope:, month: nil)
        average_for(scope:, month:)
      end
    end
  end
end
