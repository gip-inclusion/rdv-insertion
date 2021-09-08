class CreateApplicant < BaseService
  def initialize(applicant_data:, rdv_solidarites_session:, department:)
    @applicant_data = applicant_data
    @rdv_solidarites_session = rdv_solidarites_session
    @department = department
  end

  def call
    create_applicant!
    result.augmented_applicant = AugmentedApplicant.new(applicant, result.rdv_solidarites_user)
  end

  private

  def create_applicant!
    fail! unless create_applicant_transaction

    fail! unless assign_rdv_solidarites_user_attributes
  end

  def create_applicant_transaction
    Applicant.transaction do
      create_applicant_in_db
      raise ActiveRecord::Rollback if failed?

      create_user_in_rdv_solidarites
      raise ActiveRecord::Rollback if failed?

      true
    end
  end

  def assign_rdv_solidarites_user_attributes
    return true if applicant.update(
      rdv_solidarites_user_id: result.rdv_solidarites_user.id,
      phone_number_formatted: result.rdv_solidarites_user.phone_number_formatted
    )

    result.errors << applicant.errors.full_messages.to_sentence
    false
  end

  def create_applicant_in_db
    if applicant.save
      result.applicant = applicant
    else
      result.errors << applicant.errors.full_messages.to_sentence
    end
  end

  def applicant
    @applicant ||= Applicant.new(applicant_attributes)
  end

  def applicant_attributes
    { department: @department }.merge(
      @applicant_data.slice(*Applicant.attribute_names.map(&:to_sym)).compact
    )
  end

  def create_user_in_rdv_solidarites
    if create_rdv_solidarites_user_service.success?
      result.rdv_solidarites_user = create_rdv_solidarites_user_service.rdv_solidarites_user
    else
      result.errors += create_rdv_solidarites_user_service.errors
    end
  end

  def create_rdv_solidarites_user_service
    @create_rdv_solidarites_user_service ||= CreateRdvSolidaritesUser.call(
      user_attributes: rdv_solidarites_user_attributes,
      rdv_solidarites_session: @rdv_solidarites_session
    )
  end

  def rdv_solidarites_user_attributes
    user_attributes = {
      organisation_ids: [@department.rdv_solidarites_organisation_id],
      # if we notify from rdv-insertion we don't from rdv-solidarites
      notify_by_sms: !@department.notify_applicant?,
      notify_by_email: !@department.notify_applicant?
    }.merge(
      @applicant_data.slice(*RdvSolidaritesUser::USER_ATTRIBUTES).compact
    ).deep_symbolize_keys

    return user_attributes unless applicant.conjoint?

    # we do not send the same email for the conjoint
    user_attributes.except(:email)
  end
end
