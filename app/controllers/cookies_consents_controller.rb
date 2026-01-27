class CookiesConsentsController < ApplicationController
  def new
    @cookies_consent = current_agent.build_cookies_consent(
      tracking_accepted: true,
      support_accepted: true
    )
  end

  def edit
    @cookies_consent = current_agent.cookies_consent
  end

  def create
    @cookies_consent = current_agent.build_cookies_consent
    @cookies_consent.assign_attributes(cookies_consent_params)
    save_and_respond
  end

  def update
    @cookies_consent = current_agent.cookies_consent
    @cookies_consent.assign_attributes(cookies_consent_params)
    save_and_respond
  end

  private

  def save_and_respond
    if @cookies_consent.save
      redirect_back_or_to(authenticated_root_path, notice: "Vos préférences ont été enregistrées.")
    else
      redirect_back_or_to(
        authenticated_root_path, alert: "Une erreur est survenue lors de l'enregistrement de vos préférences: " \
                                        "#{@cookies_consent.errors.full_messages.join(', ')}"
      )
    end
  end

  def cookies_consent_params
    params.expect(cookies_consent: [:support_accepted, :tracking_accepted])
  end
end
