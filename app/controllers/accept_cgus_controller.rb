class AcceptCgusController < ApplicationController
  def create
    if accept_cgu.success?
      head :no_content
    else
      turbo_stream_display_custom_error_modal(
        title: "L'acceptation n'a pas fonctionné",
        description: "Veuillez contacter le support si le problème persiste.",
        errors: accept_cgu.errors
      )
    end
  end

  private

  def accept_cgu
    @accept_cgu ||= Agents::AcceptCgus.call(
      cgu_accepted: params[:cgu_accepted] == "1",
      agent: current_agent
    )
  end
end
