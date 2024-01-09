class ParticipationsController < ApplicationController
  before_action :set_participation, only: [:update]

  def update
    participation_update = Participations::Update.call(
      participation: @participation,
      participation_params: participation_params
    )

    @success = participation_update.success?
    flash.now[:error] = participation_update.errors.join(" ") unless @success
  end

  private

  def set_participation
    @participation = Participation.find(params[:id])
  end

  def participation_params
    params.require(:participation).permit(:status)
  end
end
