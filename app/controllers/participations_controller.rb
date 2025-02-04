class ParticipationsController < ApplicationController
  before_action :set_participation, only: [:update]

  def update
    participation_update = Participations::Update.call(
      participation: @participation,
      participation_params: participation_params
    )

    @success = participation_update.success?
    if @success
      flash.now[:success] = "Le statut du rdv a bien été modifié."
    else
      flash.now[:error] = participation_update.errors.join(", ")
    end
    respond_to :turbo_stream
  end

  private

  def set_participation
    @participation = Participation.find(params[:id])
  end

  def participation_params
    params.expect(participation: [:status])
  end
end
