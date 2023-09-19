module Participations
  class Update < BaseService
    def initialize(participation:, rdv_solidarites_session:, participation_params:)
      @participation = participation
      @rdv_solidarites_session = rdv_solidarites_session
      @participation_params = participation_params
    end

    def call
      Participation.transaction do
        update_rdv_solidarites_participation
        @participation.update!(status: @participation_params[:status])
        @participation.rdv_context.set_status
      end
    end

    def update_rdv_solidarites_participation
      @update_rdv_solidarites_participation ||= call_service!(
        RdvSolidaritesApi::UpdateParticipation,
        rdv_solidarites_session: @rdv_solidarites_session,
        rdv_solidarites_rdvs_user_id: @participation.rdv_solidarites_participation_id,
        participation_attributes: @participation_params
      )
    end
  end
end
