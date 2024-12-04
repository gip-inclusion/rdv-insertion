class AcceptCgusController < ApplicationController
  def create
    if params[:cgu_accepted]
      current_agent.update!(cgu_accepted_at: Time.zone.now)
    else
      flash[:alert] = "Vous devez accepter les CGU pour continuer"
      redirect_to root_path
    end
  end
end
