class SaveApplicant < BaseService
  def initialize(applicant:, organisation:, rdv_solidarites_session:)
    @applicant = applicant
    @organisation = organisation
    @rdv_solidarites_session = rdv_solidarites_session
  end

  def call
    Applicant.transaction do
      save_record!(@applicant)
      upsert_rdv_solidarites_user!
      assign_rdv_solidarites_user_id! unless @applicant.rdv_solidarites_user_id?
    end
  end

  private

  def upsert_rdv_solidarites_user!
    call_service!(
      UpsertRdvSolidaritesUser,
      rdv_solidarites_session: @rdv_solidarites_session,
      rdv_solidarites_organisation_id: @organisation.rdv_solidarites_organisation_id,
      rdv_solidarites_user_attributes: rdv_solidarites_user_attributes,
      rdv_solidarites_user_id: @applicant.rdv_solidarites_user_id
    )
  end

  def assign_rdv_solidarites_user_id!
    @applicant.rdv_solidarites_user_id = @upsert_rdv_solidarites_user_service.rdv_solidarites_user_id
    save_record!(@applicant)
  end

  def rdv_solidarites_user_attributes
    user_attributes = {
      # if we notify from rdv-insertion we don't from rdv-solidarites
      notify_by_sms: !@organisation.notify_applicant?,
      notify_by_email: !@organisation.notify_applicant?
    }.merge(
      @applicant.attributes.symbolize_keys.slice(*Applicant::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES)
    )

    return user_attributes if @applicant.demandeur? || @applicant.rdv_solidarites_user_id?

    # we do not send the same email for the conjoint on creation
    user_attributes.except(:email)
  end
end
