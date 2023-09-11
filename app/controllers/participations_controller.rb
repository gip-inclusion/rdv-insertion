class ParticipationsController < ApplicationController
  before_action :set_participation, only: [:edit, :update]

  def edit; end

  def update
    participation_update = RdvSolidaritesApi::UpdateParticipation.call(
      rdv_solidarites_session: rdv_solidarites_session,
      rdv_solidarites_rdv_id: @participation.rdv.rdv_solidarites_rdv_id,
      rdv_solidarites_user_id: @participation.applicant.rdv_solidarites_user_id,
      participation_attributes: participation_params
    )

    if participation_update.success?
      @participation.update!(status: participation_params[:status])
      @participation.rdv_context.set_status
    else
      flash.now[:error] = "Impossible de changer le statut de ce rendez-vous."
    end
  end

  private

  def set_participation
    @participation = Participation.find(params[:id])
  end

  def participation_params
    params.require(:participation).permit(:status)
  end
end
