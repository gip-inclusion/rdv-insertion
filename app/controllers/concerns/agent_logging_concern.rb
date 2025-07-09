module AgentLoggingConcern
  extend ActiveSupport::Concern

  included do
    around_action :with_agent_logging_tag
  end

  private

  def with_agent_logging_tag(&)
    if current_agent.present?
      Rails.logger.tagged("agent_id: #{current_agent.id}", &)
    else
      yield
    end
  end
end
