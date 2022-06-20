class SaveApplicant < BaseService
  def initialize(applicant:, organisation:, rdv_solidarites_session:)
    @applicant = applicant
    @organisation = organisation
    @rdv_solidarites_session = rdv_solidarites_session
  end

  def call
    Applicant.transaction do
      assign_organisation
      save_record!(@applicant)
      upsert_rdv_solidarites_user
      assign_rdv_solidarites_user_id unless @applicant.rdv_solidarites_user_id?
    end
  end

  private

  def assign_organisation
    @applicant.organisations = (@applicant.organisations.to_a + [@organisation]).uniq
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
    return user_attributes if @applicant.demandeur?

    # we do not send the email to rdv-s for the conjoint
    user_attributes.except(:email)
  end
end
