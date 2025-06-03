module OutgoingWebhooks
  module FranceTravail
    class BaseJob < ApplicationJob
      include LockedAndOrderedJobs

      discard_on FranceTravailApi::RetrieveUserToken::NoMatchingUser
      discard_on ActiveRecord::RecordNotFound

      def self.lock_key(participation_id:, **)
        "#{base_lock_key}:#{participation_id}"
      end

      def self.job_timestamp(timestamp:, **)
        timestamp
      end
    end
  end
end
