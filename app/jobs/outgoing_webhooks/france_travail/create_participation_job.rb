module OutgoingWebhooks
  module FranceTravail
    class CreateParticipationJob < BaseJob
      def perform(participation_id:, timestamp:)
        call_service!(FranceTravailApi::CreateParticipation, participation_id: participation_id, timestamp: timestamp)
      end
    end
  end
end
