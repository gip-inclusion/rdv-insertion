module Participations
  class Update < BaseService
    def initialize(participation:, participation_params:)
      @participation = participation
      @participation_params = participation_params
    end

    def call
      Participation.transaction do
        update_rdv_solidarites_participation
        @participation.update!(@participation_params)

        if @participation_params[:status].present?
          @participation.rdv_context.set_status
          @participation.rdv_context.save!
        end
      end
    end

    def update_rdv_solidarites_participation
      @update_rdv_solidarites_participation ||= call_service!(
        RdvSolidaritesApi::UpdateParticipation,
        rdv_solidarites_participation_id: @participation.rdv_solidarites_participation_id,
        participation_attributes: @participation_params
      )
    end
  end
end
