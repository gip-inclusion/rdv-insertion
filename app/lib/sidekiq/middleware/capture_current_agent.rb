module Sidekiq
  module Middleware
    class CaptureCurrentAgent
      def call(_worker_class, job, _queue, _redis_pool)
        # Store the current agent id in the job payload
        # The current_agent_id and whodunnit could be already set if it is a retry
        job["current_agent_id"] = Current.agent&.id if job["current_agent_id"].nil?
        job["whodunnit"] = paper_trail_whodunnit_for_sidekiq(PaperTrail.request.whodunnit, job) if job["whodunnit"].nil?
        yield
      end

      private

      def paper_trail_whodunnit_for_sidekiq(whodunnit, job)
        if whodunnit.present?
          format_paper_trail_whodunnit(whodunnit, job_class(job))
        else
          compute_paper_trail_whodunnit(job_class(job))
        end
      end

      def format_paper_trail_whodunnit(whodunnit, job_class)
        return whodunnit if whodunnit.start_with?("[Sidekiq]")

        "[Sidekiq] #{whodunnit} - job: #{job_class}"
      end

      def compute_paper_trail_whodunnit(job_class)
        if Current.agent
          "[Agent via Sidekiq] #{Current.agent.name_for_paper_trail} - job: #{job_class}"
        else
          "[Sidekiq sans agent] - job: #{job_class}"
        end
      end

      def job_class(job)
        job["args"]&.first&.dig("job_class")
      end
    end
  end
end
