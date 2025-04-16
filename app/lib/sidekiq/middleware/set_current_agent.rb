module Sidekiq
  module Middleware
    class SetCurrentAgent
      def call(_worker, job, _queue)
        set_current_agent(job)
        PaperTrail.request.whodunnit = job["whodunnit"]
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
    end
  end
end
