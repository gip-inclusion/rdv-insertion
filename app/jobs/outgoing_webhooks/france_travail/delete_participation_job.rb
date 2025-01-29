module OutgoingWebhooks
  module FranceTravail
    class DeleteParticipationJob < BaseJob
      def perform(participation_id:, france_travail_id:, user_id:, timestamp:)
        call_service!(FranceTravailApi::DeleteParticipation,
                      participation_id: participation_id,
                      france_travail_id: france_travail_id,
                      user_id: user_id, timestamp: timestamp)
      end
    end
  end
end
