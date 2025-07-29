module OutgoingWebhooks
  module FranceTravail
    class UpsertParticipationJob < BaseJob
      def perform(participation_id:, timestamp:)
        participation = Participation.find_by(id: participation_id)

        return unless participation&.eligible_for_france_travail_webhook?

        if participation.france_travail_id?
          call_service!(FranceTravailApi::UpdateParticipation, participation:, timestamp:)
        else
          call_service!(FranceTravailApi::CreateParticipation, participation:, timestamp:)
        end
      end
    end
  end
end
