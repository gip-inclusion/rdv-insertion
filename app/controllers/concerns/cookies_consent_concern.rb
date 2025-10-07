module CookiesConsentConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_should_display_cookies_consent, if: -> { request.get? }
    before_action :set_cookies_consent_for_form, if: -> { logged_in? }
  end

  private

  def set_should_display_cookies_consent
    @should_display_cookies_consent = logged_in? && current_agent.cookies_consent.nil? && !agent_impersonated?
  end

  def set_cookies_consent_for_form
    @cookies_consent = current_agent.cookies_consent || current_agent.build_cookies_consent(
      tracking_accepted: true,
      support_accepted: true
    )
  end
end
