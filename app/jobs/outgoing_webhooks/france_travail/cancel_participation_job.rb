module OutgoingWebhooks
  module FranceTravail
    class CancelParticipationJob < BaseJob
      def perform(participation_id:, france_travail_id:, user_id:, timestamp:)
        user = User.find_by(id: user_id)
        # if the user is deleted, it means that the participation is old and does not mean it has been cancelled,
        # so no reason to cancel it here
        return unless user

        cancel_result = FranceTravailApi::CancelParticipation.call(
          participation_id: participation_id,
          france_travail_id: france_travail_id,
          user: user,
          timestamp: timestamp
        )

        return if cancel_result.error_type == :participation_not_found

        raise ApplicationJob::FailedServiceError, "Errors: #{cancel_result.errors}" if cancel_result.failure?
      end
    end
  end
end
