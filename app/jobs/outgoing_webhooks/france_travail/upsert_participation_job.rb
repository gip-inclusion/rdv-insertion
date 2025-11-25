module OutgoingWebhooks
  module FranceTravail
    class UpsertParticipationJob < BaseJob
      def perform(participation_id:, timestamp:)
        participation = Participation.find_by(id: participation_id)

        return unless participation&.eligible_for_france_travail_webhook?

        if participation.france_travail_id?
          begin
            call_service!(FranceTravailApi::UpdateParticipation, participation:, timestamp:)
          rescue FranceTravailApi::UpdateParticipation::ParticipationNotFound
            # If the participation was not found (ID_NON_RECONNU), we try to recreate it
            participation.update_column(:france_travail_id, nil)
            call_service!(FranceTravailApi::CreateParticipation, participation:, timestamp:)
          end
        else
          call_service!(FranceTravailApi::CreateParticipation, participation:, timestamp:)
        end
      end
    end
  end
end
