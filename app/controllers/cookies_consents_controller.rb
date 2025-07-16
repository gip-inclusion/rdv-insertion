class CookiesConsentsController < ApplicationController
  before_action :verify_cookies_consent_not_already_given, only: :create

  def create
    current_agent.cookies_consent.create!(cookies_consent_params)
    redirect_to request.referer
  end

  private

  def cookies_consent_params
    params.expect(cookies_consent: [:support_accepted, :tracking_accepted])
  end

  def verify_cookies_consent_not_already_given
    return if current_agent.cookies_consent.nil?

    redirect_to request.referer, alert: "Vous avez déjà donné votre consentement aux cookies."
  end
end
