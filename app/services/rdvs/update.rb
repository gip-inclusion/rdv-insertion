module Rdvs
  class Update < BaseService
    def initialize(rdv:, attributes:, rdv_solidarites_session:)
      @rdv = rdv
      @attributes = attributes
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      ActiveRecord::Base.transaction do
        @rdv.assign_attributes(@attributes)
        @rdv.participations.update_all(status: @attributes[:status]) if @attributes[:status].present?
        save_record!(@rdv)
        update_rdv_solidarites_rdv
      end
    end

    private

    def update_rdv_solidarites_rdv
      RdvSolidaritesApi::UpdateRdv.call(
        rdv_solidarites_session: @rdv_solidarites_session,
        rdv_solidarites_rdv_id: @rdv.rdv_solidarites_rdv_id,
        rdv_attributes: @attributes
      )
    end
  end
end
