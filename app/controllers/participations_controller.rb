class ParticipationsController < ApplicationController
  before_action :set_participation, only: [:update]

  def index
    respond_to do |format|
      format.csv { send_participations_csv }
    end
  end

  def update
    @success = Participations::Update.call(
      participation: @participation,
      rdv_solidarites_session: rdv_solidarites_session,
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

  def send_participations_csv
    send_data generate_participations.csv, filename: generate_participations.filename
  end

  def generate_participations
    @generate_participations ||= Exporters::GenerateParticipationsCsv.call(
      elements: filtered_list.users,
      structure: Current.structure,
      motif_category: filtered_list.current_motif_category
    )
  end

  def filtered_list
    @filtered_list ||= Users::FilterList.new(
      params:,
      page:,
      scoped_user_class: policy_scope(User)
    ).perform
  end
end
