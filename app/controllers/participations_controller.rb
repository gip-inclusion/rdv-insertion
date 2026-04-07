class ParticipationsController < ApplicationController
  before_action :set_participation, only: [:update]

  def update
    if participation_update.success?
      redirect_to structure_user_follow_ups_path(user_id: @participation.user_id)
    else
      turbo_stream_display_error_modal(participation_update.errors)
    end
  end

  private

  def set_participation
    @participation = Participation.find(params[:id])
  end

  def participation_params
    params.expect(participation: [:status])
  end

  def participation_update
    @participation_update ||= Participations::Update.call(
      participation: @participation,
      participation_params: participation_params
    )
  end
end
