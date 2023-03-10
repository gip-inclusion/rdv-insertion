# rubocop:disable Metrics/ClassLength
class RdvSolidaritesClient
  def initialize(rdv_solidarites_session:)
    @rdv_solidarites_session = rdv_solidarites_session
    @url = ENV["RDV_SOLIDARITES_URL"]
  end

  def create_user(request_body)
    Faraday.post(
      "#{@url}/api/v1/users",
      request_body.to_json,
      request_headers
    )
  end

  def update_user(user_id, request_body = {})
    Faraday.patch(
      "#{@url}/api/v1/users/#{user_id}",
      request_body.to_json,
      request_headers
    )
  end

  def update_organisation(organisation_id, request_body = {})
    Faraday.patch(
      "#{@url}/api/v1/organisations/#{organisation_id}",
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

  def get_organisation_user(user_id, organisation_id)
    Faraday.get(
      "#{@url}/api/v1/organisations/#{organisation_id}/users/#{user_id}",
      {},
      request_headers
    )
  end

  def get_invitation(invitation_token)
    Faraday.get(
      "#{@url}/api/v1/invitations/#{invitation_token}",
      {},
      request_headers
    )
  end

  def create_user_profile(user_id, organisation_id)
    Faraday.post(
      "#{@url}/api/v1/user_profiles",
      { user_id: user_id, organisation_id: organisation_id }.to_json,
      request_headers
    )
  end

  def delete_user_profile(user_id, organisation_id)
    Faraday.delete(
      "#{@url}/api/v1/user_profiles",
      { user_id: user_id, organisation_id: organisation_id },
      request_headers
    )
  end

  def get_organisation_users(organisation_id, page = 1, **kwargs)
    Faraday.get(
      "#{@url}/api/v1/organisations/#{organisation_id}/users",
      { page: page }.merge(**kwargs),
      request_headers
    )
  end

  def get_users(user_params = {})
    Faraday.get(
      "#{@url}/api/v1/users",
      user_params,
      request_headers
    )
  end

  def get_organisations(geo_params = {})
    Faraday.get(
      "#{@url}/api/v1/organisations",
      geo_params,
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

  def get_motifs(organisation_id, service_id = nil)
    Faraday.get(
      "#{@url}/api/v1/organisations/#{organisation_id}/motifs",
      {
        active: true, reservable_online: true
      }.merge(service_id.present? ? { service_id: service_id } : {}),
      request_headers
    )
  end

  def get_organisation_rdvs(organisation_id, page = 1)
    Faraday.get(
      "#{@url}/api/v1/organisations/#{organisation_id}/rdvs",
      { page: page },
      request_headers
    )
  end

  def validate_token
    Faraday.get(
      "#{@url}/api/v1/auth/validate_token",
      {},
      request_headers
    )
  end

  def create_referent_assignation(user_id, agent_id)
    Faraday.post(
      "#{@url}/api/v1/referent_assignations",
      { user_id: user_id, agent_id: agent_id }.to_json,
      request_headers
    )
  end

  def delete_referent_assignation(user_id, agent_id)
    Faraday.delete(
      "#{@url}/api/v1/referent_assignations",
      { user_id: user_id, agent_id: agent_id },
      request_headers
    )
  end

  private

  def request_headers
    base_headers = {
      "Content-Type" => "application/json",
      "uid" => @rdv_solidarites_session.uid,
      "access_token" => @rdv_solidarites_session.access_token,
      "client" => @rdv_solidarites_session.client
    }

    x_agent_headers = {
      "x_agent_auth_signature" => @rdv_solidarites_session.x_agent_auth_signature
    }

    base_headers.merge(@rdv_solidarites_session.x_agent_auth_signature.present? ? x_agent_headers : {})
  end
end
# rubocop:enable Metrics/ClassLength
