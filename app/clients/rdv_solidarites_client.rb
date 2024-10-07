# rubocop:disable Metrics/ClassLength
class RdvSolidaritesClient
  def initialize(auth_headers:)
    @auth_headers = auth_headers
    @url = ENV["RDV_SOLIDARITES_URL"]
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
      "#{@url}/api/rdvinsertion/users/#{user_id}",
      {},
      request_headers
    )
  end

  def create_user_profiles(user_id, organisation_ids)
    Faraday.post(
      "#{@url}/api/rdvinsertion/user_profiles/create_many",
      { user_id: user_id, organisation_ids: organisation_ids }.to_json,
      request_headers
    )
  end

  def create_referent_assignations(user_id, agent_ids)
    Faraday.post(
      "#{@url}/api/rdvinsertion/referent_assignations/create_many",
      { user_id: user_id, agent_ids: agent_ids }.to_json,
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

  def delete_user_profile(user_id, organisation_id)
    Faraday.delete(
      "#{@url}/api/v1/user_profiles",
      { user_id: user_id, organisation_id: organisation_id },
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
      "#{@url}/api/v1/users/#{user_id}/rdv_invitation_token",
      request_body.to_json,
      request_headers
    )
  end

  def get_creneau_availability(link_params = {})
    Faraday.get(
      "#{@url}/api/rdvinsertion/invitations/creneau_availability",
      link_params,
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

  def create_webhook_endpoint(organisation_id, subscriptions, trigger)
    Faraday.post(
      "#{@url}/api/v1/organisations/#{organisation_id}/webhook_endpoints",
      {
        target_url: "#{ENV['HOST']}/rdv_solidarites_webhooks",
        secret: ENV["RDV_SOLIDARITES_SECRET"],
        subscriptions: subscriptions,
        trigger: trigger
      }.to_json,
      request_headers
    )
  end

  def update_webhook_endpoint(webhook_endpoint_id, organisation_id, subscriptions, trigger)
    Faraday.patch(
      "#{@url}/api/v1/organisations/#{organisation_id}/webhook_endpoints/#{webhook_endpoint_id}",
      {
        target_url: "#{ENV['HOST']}/rdv_solidarites_webhooks",
        secret: ENV["RDV_SOLIDARITES_SECRET"],
        subscriptions: subscriptions,
        trigger: trigger
      }.to_json,
      request_headers
    )
  end

  def update_participation(participation_id, request_body = {})
    Faraday.patch(
      "#{@url}/api/v1/participations/#{participation_id}",
      request_body.to_json,
      request_headers
    )
  end

  def create_motif_category(request_body)
    Faraday.post(
      "#{@url}/api/rdvinsertion/motif_categories",
      request_body.to_json,
      request_headers
    )
  end

  def create_motif_category_territory(motif_category_short_name, organisation_id)
    Faraday.post(
      "#{@url}/api/rdvinsertion/motif_category_territories",
      { motif_category_short_name: motif_category_short_name, organisation_id: organisation_id }.to_json,
      request_headers
    )
  end

  private

  def request_headers
    @auth_headers.merge("Content-Type" => "application/json")
  end
end
# rubocop:enable Metrics/ClassLength
