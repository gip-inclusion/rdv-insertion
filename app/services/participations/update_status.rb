module Participations
  class UpdateStatus < BaseService
    def initialize(participation:, status:)
      @participation = participation
      @status = status
    end

    def call
      Participation.transaction do
        update_rdv_solidarites_participation
        @participation.update!(status: @status)
        @participation.follow_up.set_status
        @participation.follow_up.save!
      end
    end

    private

    def update_rdv_solidarites_participation
      @update_rdv_solidarites_participation ||=
        if @participation.collectif?
          call_service!(
            RdvSolidaritesApi::UpdateParticipation,
            rdv_solidarites_participation_id: @participation.rdv_solidarites_participation_id,
            participation_attributes: { status: @status }
          )
        else
          call_service!(
            RdvSolidaritesApi::UpdateRdvStatus,
            rdv_solidarites_rdv_id: @participation.rdv_solidarites_rdv_id,
            status: @status
          )
        end
    end
  end
end
