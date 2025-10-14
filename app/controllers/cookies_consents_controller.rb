class CookiesConsentsController < ApplicationController
  def new
    @cookies_consent = current_agent.build_cookies_consent(
      tracking_accepted: true,
      support_accepted: true
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "remote_modal",
          partial: "common/cookies_consent_customization_modal",
          locals: { cookies_consent: @cookies_consent }
        )
      end
    end
  end

  def edit
    @cookies_consent = current_agent.cookies_consent

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "remote_modal",
          partial: "common/cookies_consent_customization_modal",
          locals: { cookies_consent: @cookies_consent }
        )
      end
    end
  end

  def create
    save_cookies_consent
  end

  def update
    save_cookies_consent
  end

  private

  def save_cookies_consent
    cookies_consent = current_agent.cookies_consent || current_agent.build_cookies_consent
    cookies_consent.assign_attributes(cookies_consent_params)

    if cookies_consent.save
      redirect_back(notice: "Vos préférences ont été enregistrées.", fallback_location: authenticated_root_path)
    else
      redirect_back(
        alert: "Une erreur est survenue lors de l'enregistrement de vos préférences: " \
               "#{cookies_consent.errors.full_messages.join(', ')}",
        fallback_location: authenticated_root_path
      )
    end
  end

  def cookies_consent_params
    params.expect(cookies_consent: [:support_accepted, :tracking_accepted])
  end
end
