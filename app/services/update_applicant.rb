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
      update_phone_number!
    end
  end

  private

  def update_phone_number!
    return if @applicant.update(
      phone_number_formatted: rdv_solidarites_user.phone_number_formatted
    )

    result.errors << applicant.errors.full_messages.to_sentence
    fail!
  end

  def update_applicant_in_db!
    return if @applicant.update(applicant_data)

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
    applicant_data
      .except(:phone_number_formatted)
      .merge(phone_number: applicant_data[:phone_number_formatted])
      .slice(*RdvSolidarites::User::RECORD_ATTRIBUTES)
  end

  def applicant_data
    if @applicant_data[:'birth_date(1i)'].present?
      @applicant_data
        .except(:'birth_date(1i)', :'birth_date(2i)', :'birth_date(3i)')
        .merge(birth_date: "#{@applicant_data[:'birth_date(1i)']}/"\
                           "#{@applicant_data[:'birth_date(2i)']}/#{@applicant_data[:'birth_date(3i)']}")
    else
      @applicant_data
    end
  end
end
