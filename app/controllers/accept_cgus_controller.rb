class AcceptCgusController < ApplicationController
  def create
    if accept_cgu.success?
      head :no_content
    else
      turbo_stream_display_error_modal(@accept_cgu.errors)
    end
  end

  private

  def accept_cgu
    @accept_cgu ||= Agents::AcceptCgus.call(
      cgu_accepted: params[:cgu_accepted],
      agent: current_agent
    )
  end
end
