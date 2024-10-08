module Sidekiq
  module Middleware
    class SetCurrentAgent
      def call(_worker, job, _queue)
        set_current_agent(job)
        yield
      end

      private

      def set_current_agent(job) # rubocop:disable Naming/AccessorMethodName
        return unless job["current_agent_id"]

        Current.agent = Agent.find(job["current_agent_id"].to_i)
      end
    end
  end
end
