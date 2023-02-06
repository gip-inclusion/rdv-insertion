module Applicants
  class Save < BaseService
    def initialize(applicant:, organisation:, rdv_solidarites_session:)
      @applicant = applicant
      @organisation = organisation
      @rdv_solidarites_session = rdv_solidarites_session
    end

    def call
      Applicant.transaction do
        assign_organisation
        save_record!(@applicant)
        create_rdv_contexts
        upsert_rdv_solidarites_user
        assign_rdv_solidarites_user_id unless @applicant.rdv_solidarites_user_id?
      end
    end

    private

    def assign_organisation
      @applicant.organisations = (@applicant.organisations.to_a + [@organisation]).uniq
    end

    # we link the applicant to all the motif categories the organisation can invite to
    def create_rdv_contexts
      RdvContext.with_advisory_lock "setting_rdv_context_for_applicant_#{@applicant.id}" do
        @organisation.motif_categories.each do |motif_category|
          RdvContext.find_or_create_by!(motif_category: motif_category, applicant: @applicant)
        end
      end
    end

    def upsert_rdv_solidarites_user
      @upsert_rdv_solidarites_user ||= call_service!(
        UpsertRdvSolidaritesUser,
        rdv_solidarites_session: @rdv_solidarites_session,
        rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id,
        rdv_solidarites_user_attributes: rdv_solidarites_user_attributes,
        rdv_solidarites_user_id: @applicant.rdv_solidarites_user_id
      )
    end

    def assign_rdv_solidarites_user_id
      @applicant.rdv_solidarites_user_id = upsert_rdv_solidarites_user.rdv_solidarites_user_id
      save_record!(@applicant)
    end

    def rdv_solidarites_user_attributes
      user_attributes = @applicant.attributes
                                  .symbolize_keys
                                  .slice(*Applicant::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES)
                                  .transform_values(&:presence)
                                  .compact
      return user_attributes if @applicant.demandeur? || @applicant.role.nil?

      # we do not send the email to rdv-s for the conjoint
      user_attributes.except(:email) if @applicant.conjoint?
    end
  end
end
