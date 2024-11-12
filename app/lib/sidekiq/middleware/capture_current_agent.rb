module Sidekiq
  module Middleware
    class CaptureCurrentAgent
      def call(_worker_class, job, _queue, _redis_pool)
        # Store the current agent id in the job payload
        job["current_agent_id"] = Current.agent&.id if job["current_agent_id"].nil?
        yield
      end
    end
  end
end
