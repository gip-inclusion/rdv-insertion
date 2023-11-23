module Stats
  module CounterCache
    class DaysBetweenInvitationAndRdv
      include EventSubscriber
      include Counter

      catch_events :create_participation_successful, if: lambda { |participation|
        participation.rdv_context.participations.size < 2 &&
          participation.rdv_context.invitations.present?
      }

      def self.value(scope:, month: nil)
        average_for(scope:, month:)
      end

      def process_event
        offset = participation.rdv_context.time_between_invitation_and_rdv_in_days
        append(value: offset)
      end
    end
  end
end
