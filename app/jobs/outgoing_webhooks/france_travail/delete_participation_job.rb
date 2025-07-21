module OutgoingWebhooks
  module FranceTravail
    class DeleteParticipationJob < BaseJob
      def perform(participation_id:, france_travail_id:, user_id:, timestamp:)
        user = User.find_by(id: user_id)
        # if user is deleted, it means that the participation is old and does not mean it has been cancelled,
        # so no reason to cancel it here (which is what Delete does)
        return unless user

        call_service!(FranceTravailApi::DeleteParticipation,
                      participation_id: participation_id,
                      france_travail_id: france_travail_id,
                      user: user,
                      timestamp: timestamp)
      end
    end
  end
end
