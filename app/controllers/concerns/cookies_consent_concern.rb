module CookiesConsentConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_should_display_cookies_consent, if: -> { request.get? }
    helper_method :default_cookies_consent
  end

  private

  def set_should_display_cookies_consent
    @should_display_cookies_consent = logged_in? && current_agent.cookies_consent.nil? && !agent_impersonated?
  end

  def default_cookies_consent
    @default_cookies_consent ||= current_agent.build_cookies_consent(tracking_accepted: true, support_accepted: true)
  end
end
