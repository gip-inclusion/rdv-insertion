module OutgoingWebhooks
  module FranceTravail
    class LockedAndOrderedJobBase < ApplicationJob
      include LockedAndOrderedJobs

      def self.job_timestamp(timestamp:)
        timestamp
      end
    end
  end
end
