class CreateRdvSolidaritesUser < BaseService
  def initialize(user_attributes:, rdv_solidarites_session:)
    @user_attributes = user_attributes
    @rdv_solidarites_session = rdv_solidarites_session
  end

  def call
    create_user_in_rdv_solidarites
  end

  private

  def create_user_in_rdv_solidarites
    if rdv_solidarites_response.success?
      result.rdv_solidarites_user = RdvSolidaritesUser.new(rdv_solidarites_response_body["user"])
    else
      result.errors << "erreur RDV-Solidarités: #{rdv_solidarites_response_body['errors']}"
    end
  end

  def rdv_solidarites_response_body
    JSON.parse(rdv_solidarites_response.body)
  end

  def rdv_solidarites_response
    @rdv_solidarites_response ||= rdv_solidarites_client.create_user(@user_attributes)
  end

  def rdv_solidarites_client
    @rdv_solidarites_client ||= RdvSolidaritesClient.new(@rdv_solidarites_session)
  end
end
