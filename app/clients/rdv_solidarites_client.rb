class RdvSolidaritesClient
  def initialize(rdv_solidarites_session)
    @rdv_solidarites_session = rdv_solidarites_session
    @url = ENV['RDV_SOLIDARITES_URL']
  end

  def create_user(request_body)
    Faraday.post(
      "#{@url}/api/v1/users",
      request_body.to_json,
      request_headers
    )
  end

  def get_users(organisation_id, ids = [])
    Faraday.get(
      "#{@url}/api/v1/organisations/#{organisation_id}/users",
      ids.present? ? { ids: ids } : nil,
      request_headers
    )
  end

  private

  def request_headers
    {
      "Content-Type" => "application/json",
      "uid" => @rdv_solidarites_session['uid'],
      "access_token" => @rdv_solidarites_session['access_token'],
      "client" => @rdv_solidarites_session['client']
    }
  end
end
