module OutgoingWebhooks
  module FranceTravail
    class UpdateParticipationJob < LockedAndOrderedJobBase
      discard_on FranceTravailApi::RetrieveUserToken::UserNotFound

      def self.lock_key(participation_id:, **)
        "#{base_lock_key}:#{participation_id}"
      end

      def perform(participation_id:, timestamp:)
        call_service!(FranceTravailApi::UpdateParticipation, participation_id: participation_id, timestamp: timestamp)
      end
    end
  end
end
