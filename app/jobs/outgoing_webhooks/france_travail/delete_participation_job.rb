module OutgoingWebhooks
  module FranceTravail
    class DeleteParticipationJob < LockedAndOrderedJobBase
      discard_on FranceTravailApi::RetrieveUserToken::UserNotFound

      def self.lock_key(participation_id:, **)
        "#{base_lock_key}:#{participation_id}"
      end

      def perform(participation_id:, france_travail_id:, user_id:, timestamp:)
        call_service!(FranceTravailApi::DeleteParticipation,
                      participation_id: participation_id,
                      france_travail_id: france_travail_id,
                      user_id: user_id, timestamp: timestamp)
      end
    end
  end
end
