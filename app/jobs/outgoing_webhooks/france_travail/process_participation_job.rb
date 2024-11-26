module OutgoingWebhooks
  module FranceTravail
    class ProcessParticipationJob < LockedAndOrderedJobBase
      def self.lock_key(participation_id:)
        "#{base_lock_key}:#{participation_id}"
      end

      def perform(participation_id:, timestamp:, event:)
        call_service!(FranceTravailApi::ProcessParticipation, participation_id: participation_id, timestamp: timestamp,
                                                              event: event)
      end
    end
  end
end
