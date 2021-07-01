class RetrieveRdvSolidaritesUsers < BaseService
  def initialize(ids:, rdv_solidarites_session:, organisation_id:, page:)
    @ids = ids
    @organisation_id = organisation_id
    @rdv_solidarites_session = rdv_solidarites_session
    @page = page
  end

  def call
    result.rdv_solidarites_users = []
    return if @ids.empty?

    retrieve_users
  end

  private

  def retrieve_users
    if rdv_solidarites_response.success?
      treat_response
    else
      result.errors << "erreur RDV-Solidarités: #{rdv_solidarites_response_body['errors']}"
    end
  end

  def treat_response
    rdv_solidarites_response_body['users'].each do |attributes|
      result.rdv_solidarites_users << RdvSolidaritesUser.new(attributes)
    end
    result.next_page = rdv_solidarites_response_body.dig('meta', 'next_page')
  end

  def rdv_solidarites_response_body
    JSON.parse(rdv_solidarites_response.body)
  end

  def rdv_solidarites_response
    @rdv_solidarites_response ||= rdv_solidarites_client.get_users(@organisation_id, @page, @ids)
  end

  def rdv_solidarites_client
    @rdv_solidarites_client ||= RdvSolidaritesClient.new(@rdv_solidarites_session)
  end
end
