class CreateApplicant < BaseService
  def initialize(applicant_data:, rdv_solidarites_session:, agent:)
    @applicant_data = applicant_data
    @rdv_solidarites_session = rdv_solidarites_session
    @agent = agent
  end

  def call
    @result = { errors: [] }
    create_applicant!
    @result
  end

  private

  def create_applicant!
    return unless create_applicant_transaction

    assign_rdv_solidarites_user_id
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

  def failed?
    @result[:errors].present?
  end

  def assign_rdv_solidarites_user_id
    applicant.rdv_solidarites_user_id = @result[:rdv_solidarites_user].id
    return if applicant.save

    @result[:errors] << applicant.errors.full_messages.to_sentence
  end

  def create_applicant_in_db
    if applicant.save
      @result[:applicant] = applicant
    else
      @result[:errors] << applicant.errors.full_messages.to_sentence
    end
  end

  def applicant
    @applicant ||= Applicant.new(applicant_attributes)
  end

  def applicant_attributes
    { department: @agent.department }.merge(
      @applicant_data.slice(*Applicant.attribute_names).compact
    )
  end

  def create_user_in_rdv_solidarites
    if rdv_solidarites_response.success?
      @result[:rdv_solidarites_user] = RdvSolidaritesUser.new(rdv_solidarites_response_body["user"])
    else
      @result[:errors] << "erreur RDV-Solidarités: #{rdv_solidarites_response_body['errors']}"
    end
  end

  def rdv_solidarites_response_body
    JSON.parse(rdv_solidarites_response.body)
  end

  def rdv_solidarites_response
    @rdv_solidarites_response ||= \
      rdv_solidarites_client.create_user(rdv_solidarites_user_attributes)
  end

  def rdv_solidarites_user_attributes
    user_attributes = {
      organisation_ids: [@agent.rdv_solidarites_organisation_id]
    }.merge(
      @applicant_data.slice(*RdvSolidaritesUser::USER_ATTRIBUTES).compact
    ).deep_symbolize_keys

    return user_attributes unless applicant.conjoint?

    # we do not send the same email for the conjoint
    user_attributes.except(:email)
  end

  def rdv_solidarites_client
    @rdv_solidarites_client ||= RdvSolidaritesClient.new(@rdv_solidarites_session)
  end
end
