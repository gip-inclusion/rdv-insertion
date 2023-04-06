# rubocop:disable Metrics/ClassLength
class RdvSolidaritesClient
  def initialize(rdv_solidarites_session:)
    @rdv_solidarites_session = rdv_solidarites_session
    @url = ENV["RDV_SOLIDARITES_URL"]
  end

  def get_user(user_id)
    Faraday.get(
      "#{@url}/api/v1/users/#{user_id}",
      {},
      request_headers
    )
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

  def get_organisation(organisation_id)
    Faraday.get(
      "#{@url}/api/v1/organisations/#{organisation_id}",
      {},
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

  def get_webhook_endpoint(organisation_id)
    # there is a unique webhook per organisation for a given target_url, so returns a collection with 1 result max
    Faraday.get(
      "#{@url}/api/v1/organisations/#{organisation_id}/webhook_endpoints",
      { target_url: "#{ENV['HOST']}/rdv_solidarites_webhooks" },
      request_headers
    )
  end

  def create_webhook_endpoint(organisation_id, subscriptions)
    Faraday.post(
      "#{@url}/api/v1/organisations/#{organisation_id}/webhook_endpoints",
      {
        target_url: "#{ENV['HOST']}/rdv_solidarites_webhooks",
        secret: ENV["RDV_SOLIDARITES_SECRET"],
        subscriptions: subscriptions
      }.to_json,
      request_headers
    )
  end

  def update_webhook_endpoint(webhook_endpoint_id, organisation_id, subscriptions)
    Faraday.patch(
      "#{@url}/api/v1/organisations/#{organisation_id}/webhook_endpoints/#{webhook_endpoint_id}",
      {
        target_url: "#{ENV['HOST']}/rdv_solidarites_webhooks",
        secret: ENV["RDV_SOLIDARITES_SECRET"],
        subscriptions: subscriptions
      }.to_json,
      request_headers
    )
  end

  private

  def request_headers
    @rdv_solidarites_session.to_h.merge("Content-Type" => "application/json")
  end
end
# rubocop:enable Metrics/ClassLength
