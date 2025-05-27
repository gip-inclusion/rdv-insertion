module CrispConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_should_display_crisp_chatbox, if: -> { request.get? }
  end

  private

  def set_should_display_crisp_chatbox
    @should_display_crisp_chatbox = current_agent.present? && !agent_impersonated? && ENV["ENABLE_CRISP"] == "true"
  end
end
