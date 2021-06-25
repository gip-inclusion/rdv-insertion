class FetchRdvSolidaritesUsers < BaseService
  def initialize(ids:, rdv_solidarites_session:, organisation_id:)
    @ids = ids
    @organisation_id = organisation_id
    @rdv_solidarites_session = rdv_solidarites_session
  end

  def call
    @result = { errors: [], rdv_solidarites_users: [] }
    return @result if @ids.empty?

    fetch_users!
    @result
  end

  private

  def fetch_users!
    if rdv_solidarites_response.success?
      rdv_solidarites_response_body['users'].each do |attributes|
        @result[:rdv_solidarites_users] << RdvSolidaritesUser.new(attributes)
      end
    else
      @result[:errors] << "erreur RDV-Solidarités: #{rdv_solidarites_response_body['errors']}"
    end
  end

  def rdv_solidarites_response_body
    JSON.parse(rdv_solidarites_response.body)
  end

  def rdv_solidarites_response
    @rdv_solidarites_response ||= \
      rdv_solidarites_client.get_users(@organisation_id, @ids)
  end

  def rdv_solidarites_client
    @rdv_solidarites_client ||= RdvSolidaritesClient.new(@rdv_solidarites_session)
  end
end
