module RdvSolidaritesApi
  class RetrieveUserReferentAssignations < Base
    def initialize(rdv_solidarites_user_id:)
      @rdv_solidarites_user_id = rdv_solidarites_user_id
    end

    def call
      request!
      result.referent_assignations =
        rdv_solidarites_response_body["referent_assignations"].map do |referent_assignation_attributes|
          RdvSolidarites::ReferentAssignation.new(referent_assignation_attributes)
        end
    end

    private

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.get_user_referent_assignations(@rdv_solidarites_user_id)
    end
  end
end
