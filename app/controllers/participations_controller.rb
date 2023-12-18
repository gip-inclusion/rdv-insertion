class ParticipationsController < ApplicationController
  before_action :set_participation, only: [:update]

  def update
    @success = Participations::Update.call(
      participation: @participation,
      participation_params: participation_params
    ).success?

    flash.now[:error] = "Impossible de changer le statut de ce rendez-vous." unless @success
  end

  private

  def set_participation
    @participation = Participation.find(params[:id])
  end

  def participation_params
    params.require(:participation).permit(:status)
  end
end
