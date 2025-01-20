module FeaturesConcern
  extend ActiveSupport::Concern

  included do
    before_action :should_display_crisp_chatbox, if: -> { request.get? }
  end

  private

  def should_display_crisp_chatbox
    if current_agent.nil? || agent_impersonated? || ENV["ENABLE_CRISP"] != "true"
      @should_display_crisp_chatbox = false
      return
    end

    @should_display_crisp_chatbox = true
  end
end
