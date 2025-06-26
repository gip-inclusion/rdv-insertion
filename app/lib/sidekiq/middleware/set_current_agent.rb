module Sidekiq
  module Middleware
    class SetCurrentAgent
      def call(_worker, job, _queue)
        set_current_agent(job)
        PaperTrail.request.whodunnit = job["whodunnit"]
        log_job_started(job)
        yield
      ensure
        Current.agent = nil
        PaperTrail.request.whodunnit = nil
      end

      private

      def set_current_agent(job) # rubocop:disable Naming/AccessorMethodName
        return unless job["current_agent_id"]

        Current.agent = Agent.find(job["current_agent_id"].to_i)
      end

      def log_job_started(job)
        if Current.agent.present?
          Sidekiq.logger.info "[agent_id: #{Current.agent.id}] Job started: #{job_class(job)}"
        else
          Sidekiq.logger.info "Job started: #{job_class(job)}"
        end
      end

      def job_class(job)
        job["wrapped"] || job["class"] || "Unknown"
      end
    end
  end
end
