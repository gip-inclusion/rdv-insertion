module CookiesConsentConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_should_display_cookies_consent, if: -> { request.get? }
  end

  private

  def set_should_display_cookies_consent
    @should_display_cookies_consent = logged_in? && current_agent.cookies_consent.nil? && !agent_impersonated?
  end
end
