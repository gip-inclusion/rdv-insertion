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

  def get_user(user_id)
    Faraday.get(
      "#{@url}/api/v1/users/#{user_id}",
      {},
      request_headers
    )
  end

  def get_users(organisation_id, page, ids = [])
    Faraday.get(
      "#{@url}/api/v1/organisations/#{organisation_id}/users",
      { page: page }.merge(ids.present? ? { ids: ids } : {}),
      request_headers
    )
  end

  def invite_user(user_id, request_body = {})
    Faraday.post(
      "#{@url}/api/v1/users/#{user_id}/invite",
      request_body.to_json,
      request_headers
    )
  end

  def get_motifs(organisation_id)
    Faraday.get(
      "#{@url}/api/v1/organisations/#{organisation_id}/motifs",
      { active: true, reservable_online: true },
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
