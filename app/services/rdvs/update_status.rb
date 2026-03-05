module Rdvs
  class UpdateStatus < BaseService
    def initialize(participation:, status:)
      @participation = participation
      @status = status
    end

    def call
      Participation.transaction do
        update_rdv_solidarites_rdv_status
        @participation.update!(status: @status)
        @participation.follow_up.set_status
        @participation.follow_up.save!
      end
    end

    private

    def update_rdv_solidarites_rdv_status
      @update_rdv_solidarites_rdv_status ||= call_service!(
        RdvSolidaritesApi::UpdateRdvStatus,
        rdv_solidarites_rdv_id: @participation.rdv_solidarites_rdv_id,
        status: @status
      )
    end
  end
end
