module CguConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_should_display_accept_cgu, if: -> { request.get? }
  end

  private

  def set_should_display_accept_cgu
    @should_display_accept_cgu = should_accept_cgu?
  end

  def should_accept_cgu?
    return false if current_agent.nil?
    return false if agent_impersonated?

    current_agent.cgu_accepted_at.nil?
  end
end