module OutgoingWebhooks
  module FranceTravail
    class UpsertParticipationJob < BaseJob
      def perform(participation_id:, timestamp:)
        participation = Participation.find_by(id: participation_id)

        return unless participation&.eligible_for_france_travail_webhook?

        if participation.france_travail_id?
          @update_result = FranceTravailApi::UpdateParticipation.call(participation:, timestamp:)

          handle_update_result
        else
          call_service!(FranceTravailApi::CreateParticipation, participation:, timestamp:)
        end
      end

      private

      def handle_update_result
        if @update_result.error_type == :participation_not_found
          participation.update_column(:france_travail_id, nil)
          call_service!(FranceTravailApi::CreateParticipation, participation:, timestamp:)
        elsif @update_result.failure?
          raise ApplicationJob::FailedServiceError, "Errors: #{@update_result.errors}"
        end
      end
    end
  end
end
