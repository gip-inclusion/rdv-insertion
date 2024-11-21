module Users
  class ImportAssociationsFromRdvSolidarites < BaseService
    def initialize(user:)
      @user = user
    end

    def call
      add_missing_organisations_to_user
      add_missing_referents_to_user
    end

    private

    def add_missing_organisations_to_user
      organisations_linked_to_user_in_rdv_solidarites.each do |organisation|
        @user.organisations << organisation unless @user.organisations.include?(organisation)
      end
    end

    def add_missing_referents_to_user
      referents_assigned_to_user_in_rdv_solidarites.each do |referent|
        @user.referents << referent unless @user.referents.include?(referent)
      end
    end

    def rdv_solidarites_referent_ids
      call_service!(
        RdvSolidaritesApi::RetrieveUserReferentAssignations,
        rdv_solidarites_user_id: @user.rdv_solidarites_user_id
      ).referent_assignations.map(&:agent).map(&:id)
    end

    def referents_assigned_to_user_in_rdv_solidarites
      Agent.where(rdv_solidarites_agent_id: rdv_solidarites_referent_ids)
    end

    def rdv_solidarites_organisation_ids
      call_service!(
        RdvSolidaritesApi::RetrieveUser,
        rdv_solidarites_user_id: @user.rdv_solidarites_user_id
      ).user.organisation_ids
    end

    def organisations_linked_to_user_in_rdv_solidarites
      Organisation.where(rdv_solidarites_organisation_id: rdv_solidarites_organisation_ids)
    end
  end
end
