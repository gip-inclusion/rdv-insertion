module Sidekiq
  module Middleware
    class CaptureCurrentAgent
      def call(_worker_class, job, _queue, _redis_pool)
        # Store the current agent id in the job payload
        # The current_agent_id and whodunnit could be already set if it is a retry
        job["current_agent_id"] = Current.agent&.id if job["current_agent_id"].nil?
        job["whodunnit"] = PaperTrail.request.whodunnit if job["whodunnit"].nil?
        yield
      end
    end
  end
end
