module OutgoingWebhooks
  module FranceTravail
    class ProcessParticipationJob < ApplicationJob
      def perform(participation_id:, timestamp:, event:)
        call_service!(FranceTravailApi::ProcessParticipation, participation_id: participation_id, timestamp: timestamp,
                                                              event: event)
      end
    end
  end
end
