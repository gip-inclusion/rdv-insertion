module OutgoingWebhooks
  module FranceTravail
    class UpdateParticipationJob < BaseJob
      def perform(participation_id:, timestamp:)
        call_service!(FranceTravailApi::UpdateParticipation, participation_id: participation_id, timestamp: timestamp)
      end
    end
  end
end
