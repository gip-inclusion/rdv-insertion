class CreateApplicant < BaseService
  def initialize(applicant_data:, rdv_solidarites_session:, department:)
    @applicant_data = applicant_data
    @rdv_solidarites_session = rdv_solidarites_session
    @department = department
  end

  def call
    create_applicant!
    update_applicant!
    result.applicant = applicant
  end

  private

  def create_applicant!
    Applicant.transaction do
      create_applicant_in_db!
      create_rdv_solidarites_user!
    end
  end

  def update_applicant!
    return if applicant.update(
      rdv_solidarites_user_id: rdv_solidarites_user.id,
      phone_number_formatted: rdv_solidarites_user.phone_number_formatted
    )

    result.errors << applicant.errors.full_messages.to_sentence
    fail!
  end

  def create_applicant_in_db!
    return if applicant.save

    result.errors << applicant.errors.full_messages.to_sentence
    fail!
  end

  def applicant
    @applicant ||= Applicant.new(applicant_attributes)
  end

  def applicant_attributes
    { department: @department }.merge(
      @applicant_data.slice(*Applicant.attribute_names.map(&:to_sym)).compact
    )
  end

  def create_rdv_solidarites_user!
    return if create_rdv_solidarites_user.success?

    result.errors += create_rdv_solidarites_user.errors
    fail!
  end

  def rdv_solidarites_user
    create_rdv_solidarites_user.rdv_solidarites_user
  end

  def create_rdv_solidarites_user
    @create_rdv_solidarites_user ||= CreateRdvSolidaritesUser.call(
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
      @applicant_data.slice(*RdvSolidarites::User::RECORD_ATTRIBUTES).compact
    ).deep_symbolize_keys

    return user_attributes unless applicant.conjoint?

    # we do not send the same email for the conjoint
    user_attributes.except(:email)
  end
end
