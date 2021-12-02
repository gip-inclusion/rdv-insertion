class UpdateApplicant < BaseService
  def initialize(applicant:, applicant_data:, rdv_solidarites_session:)
    @applicant = applicant
    @applicant_data = applicant_data
    @rdv_solidarites_session = rdv_solidarites_session
  end

  def call
    Applicant.transaction do
      update_applicant_in_db!
      update_rdv_solidarites_user!
    end
  end

  private

  def update_applicant_in_db!
    return if @applicant.update(@applicant_data)

    result.errors << @applicant.errors.full_messages.to_sentence
    fail!
  end

  def rdv_solidarites_user
    update_rdv_solidarites_user.rdv_solidarites_user
  end

  def update_rdv_solidarites_user!
    return if update_rdv_solidarites_user.success?

    result.errors += update_rdv_solidarites_user.errors
    fail!
  end

  def update_rdv_solidarites_user
    @update_rdv_solidarites_user ||= RdvSolidaritesApi::UpdateUser.call(
      user_attributes: rdv_solidarites_user_attributes,
      rdv_solidarites_session: @rdv_solidarites_session,
      rdv_solidarites_user_id: @applicant.rdv_solidarites_user_id
    )
  end

  def rdv_solidarites_user_attributes
    @applicant.attributes.symbolize_keys
              .slice(*Applicant::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES)
  end
end
