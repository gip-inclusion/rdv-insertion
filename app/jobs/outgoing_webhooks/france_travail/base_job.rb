module OutgoingWebhooks
  module FranceTravail
    class BaseJob < ApplicationJob
      include LockedAndOrderedJobs

      discard_on FranceTravailApi::RetrieveUserToken::NoMatchingUser,
                 FranceTravailApi::RetrieveUserToken::AccessForbidden,
                 FranceTravailApi::RetrieveUserToken::UserAddressNotFound

      retry_on FranceTravailApi::RetrieveUserToken::RateLimited, wait: :polynomially_longer, attempts: 5

      def self.lock_key(participation_id:, **)
        "#{base_lock_key}:#{participation_id}"
      end

      def self.job_timestamp(timestamp:, **)
        timestamp
      end
    end
  end
end
