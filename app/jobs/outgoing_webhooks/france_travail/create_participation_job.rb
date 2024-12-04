module OutgoingWebhooks
  module FranceTravail
    class CreateParticipationJob < LockedAndOrderedJobBase
      def self.lock_key(participation_id:, **)
        "#{base_lock_key}:#{participation_id}"
      end

      def perform(participation_id:, timestamp:)
        call_service!(FranceTravailApi::CreateParticipation, participation_id: participation_id, timestamp: timestamp)
      end
    end
  end
end
