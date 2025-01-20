class AcceptCgusController < ApplicationController
  before_action :ensure_cgus_are_accepted

  def create
    if current_agent.update(cgu_accepted_at: Time.zone.now)
      head :no_content
    else
      turbo_stream_display_custom_error_modal(
        title: "L'acceptation n'a pas fonctionné",
        errors: current_agent.errors.full_messages,
        with_support_contact: true
      )
    end
  end

  private

  def ensure_cgus_are_accepted
    return if params[:cgu_accepted] == "1"

    turbo_stream_display_error_modal(["Vous devez accepter les CGUs"])
  end
end
