module Sidekiq
  module Middleware
    class SetCurrentAgent
      def call(_worker, job, _queue)
        set_current_agent(job)
        set_paper_trail_whodunnit(job)
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

      def set_paper_trail_whodunnit(job) # rubocop:disable Naming/AccessorMethodName
        if job["whodunnit"].blank?
          job_class = job["args"]&.first&.dig("job_class")
          PaperTrail.request.whodunnit = set_paper_trail_whodunnit_from_job_class(job_class)
        else
          PaperTrail.request.whodunnit = job["whodunnit"]
        end
      end

      def set_paper_trail_whodunnit_from_job_class(job_class) # rubocop:disable Naming/AccessorMethodName
        if Current.agent
          "[Agent via Sidekiq] #{Current.agent.name_for_paper_trail} (job: #{job_class})"
        else
          "[Sidekiq sans agent] job: #{job_class}"
        end
      end
    end
  end
end
