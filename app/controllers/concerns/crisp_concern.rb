module CrispConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_should_display_crisp_chatbox, if: -> { request.get? }
  end

  private

  def set_should_display_crisp_chatbox
    @should_display_crisp_chatbox = ENV["ENABLE_CRISP"] == "true" &&
                                    logged_in? &&
                                    !agent_impersonated? &&
                                    current_agent.support_accepted?
  end
end
