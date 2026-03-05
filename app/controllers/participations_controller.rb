class ParticipationsController < ApplicationController
  before_action :set_participation, only: [:update]

  def update
    service = @participation.collectif? ? Participations::UpdateStatus : Rdvs::UpdateStatus
    result = service.call(participation: @participation, status: participation_params[:status])

    @success = result.success?
    if @success
      flash.now[:success] = "Le statut du rdv a bien été modifié."
    else
      flash.now[:error] = result.errors.join(", ")
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
