module CrispConcern
  extend ActiveSupport::Concern

  included do
    before_action :should_display_crisp_chatbox, if: -> { request.get? }
  end

  private

  def should_display_crisp_chatbox
    @should_display_crisp_chatbox = current_agent && !agent_impersonated? && ENV["ENABLE_CRISP"] == "true"
  end
end
