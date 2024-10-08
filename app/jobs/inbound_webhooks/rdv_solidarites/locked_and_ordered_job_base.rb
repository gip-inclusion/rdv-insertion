module InboundWebhooks
  module RdvSolidarites
    class LockedAndOrderedJobBase < ApplicationJob
      include LockedAndOrderedJobs

      def self.job_timestamp(_data, meta)
        meta["timestamp"]
      end
    end
  end
end
