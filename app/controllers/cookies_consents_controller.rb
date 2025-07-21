class CookiesConsentsController < ApplicationController
  before_action :verify_cookies_consent_not_already_given, only: :create

  def create
    cookies_consent = CookiesConsent.new(cookies_consent_params.merge(agent: current_agent))
    if cookies_consent.save
      redirect_to authenticated_root_path, notice: "Votre consentement a été enregistré."
    else
      redirect_to authenticated_root_path, alert: "Une erreur est survenue lors de l'enregistrement de votre consentement: " \
                                       "#{cookies_consent.errors.full_messages.join(', ')}"
    end
  end

  private

  def cookies_consent_params
    params.expect(cookies_consent: [:support_accepted, :tracking_accepted])
  end

  def verify_cookies_consent_not_already_given
    return if current_agent.cookies_consent.nil?

    redirect_to authenticated_root_path, alert: "Vous ne pouvez pas modifier les préférences des cookies."
  end
end
