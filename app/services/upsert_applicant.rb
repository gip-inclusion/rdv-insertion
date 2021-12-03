class UpsertApplicant < BaseService
  def initialize(applicant:, organisation:, applicant_data:, rdv_solidarites_session:)
    @applicant = applicant
    @organisation = organisation
    @applicant_data = applicant_data
    @rdv_solidarites_session = rdv_solidarites_session
  end

  def call
    Applicant.transaction do
      upsert_applicant_in_db!
      upsert_rdv_solidarites_user!
      set_rdv_solidarites_id!
    end
  end

  private

  def set_rdv_solidarites_id!
    return if @applicant.update(rdv_solidarites_user_id: rdv_solidarites_user.id)

    result.errors << @applicant.errors.full_messages.to_sentence
    fail!
  end

  def upsert_applicant_in_db!
    if @applicant.id?
      return if @applicant.update(@applicant_data)
    else
      @applicant.assign_attributes(applicant_attributes)
      return if @applicant.save
    end

    result.errors << @applicant.errors.full_messages.to_sentence
    fail!
  end

  def applicant_attributes
    { organisations: [@organisation] }.merge(
      @applicant_data.slice(*Applicant.attribute_names.map(&:to_sym)).compact
    )
  end

  def rdv_solidarites_user
    upsert_rdv_solidarites_user.rdv_solidarites_user
  end

  def upsert_rdv_solidarites_user!
    return if upsert_rdv_solidarites_user.success?

    result.errors += upsert_rdv_solidarites_user.errors
    fail!
  end

  def upsert_rdv_solidarites_user
    @upsert_rdv_solidarites_user ||= RdvSolidaritesApi::UpsertUser.call(
      user_attributes: rdv_solidarites_user_attributes,
      rdv_solidarites_session: @rdv_solidarites_session,
      rdv_solidarites_user_id: @applicant.rdv_solidarites_user_id
    )
  end

  def rdv_solidarites_user_attributes
    user_attributes = {
      organisation_ids: [@organisation.rdv_solidarites_organisation_id],
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
