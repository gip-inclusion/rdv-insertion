class CreneauOpeningRequestsController < ApplicationController
  before_action :set_creneau_opening_request, only: [:redirect]
  skip_before_action :authenticate_agent!, only: [:redirect_shortcut, :redirect]

  def redirect_shortcut
    redirect_to redirect_creneau_opening_requests_path(uuid: params[:uuid])
  end

  def redirect
    @creneau_opening_request.update(clicked_at: Time.zone.now)
    redirect_to @creneau_opening_request.link, allow_other_host: true
  end

  private

  def set_creneau_opening_request
    @creneau_opening_request = CreneauOpeningRequest.find_by(uuid: params[:uuid])
    return if @creneau_opening_request.present?

    redirect_to root_path, flash: { error: "Ce lien n'existe pas dans notre système." }
  end
end
