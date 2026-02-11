class RdvSolidaritesClient
  def initialize(auth_headers:)
    @auth_headers = auth_headers
  end

  def create_user(request_body)
    connection.post("/api/v1/users", request_body.to_json)
  end

  def get_user(user_id)
    connection.get("/api/rdvinsertion/users/#{user_id}")
  end

  def create_user_profiles(user_id, organisation_ids)
    connection.post("/api/rdvinsertion/user_profiles/create_many", {
      user_id: user_id, organisation_ids: organisation_ids
    }.to_json)
  end

  def create_referent_assignations(user_id, agent_ids)
    connection.post("/api/rdvinsertion/referent_assignations/create_many", {
      user_id: user_id, agent_ids: agent_ids
    }.to_json)
  end

  def get_user_referent_assignations(user_id)
    connection.get("/api/rdvinsertion/users/#{user_id}/referent_assignations")
  end

  def update_user(user_id, request_body = {})
    connection.patch("/api/v1/users/#{user_id}", request_body.to_json)
  end

  def get_organisation(organisation_id)
    connection.get("/api/v1/organisations/#{organisation_id}")
  end

  def update_organisation(organisation_id, request_body = {})
    connection.patch("/api/v1/organisations/#{organisation_id}", request_body.to_json)
  end

  def delete_user_profile(user_id, organisation_id)
    connection.delete("/api/v1/user_profiles", { user_id: user_id, organisation_id: organisation_id })
  end

  def get_organisations(geo_params = {})
    connection.get("/api/v1/organisations", geo_params)
  end

  def invite_user(user_id, request_body = {})
    connection.post("/api/v1/users/#{user_id}/rdv_invitation_token", request_body.to_json)
  end

  def get_creneau_availability(link_params = {})
    connection.get("/api/rdvinsertion/invitations/creneau_availability", link_params)
  end

  def validate_token
    connection.get("/api/v1/auth/validate_token")
  end

  def create_referent_assignation(user_id, agent_id)
    connection.post("/api/v1/referent_assignations", {
      user_id: user_id, agent_id: agent_id
    }.to_json)
  end

  def delete_referent_assignation(user_id, agent_id)
    connection.delete("/api/v1/referent_assignations", { user_id: user_id, agent_id: agent_id })
  end

  def get_webhook_endpoint(organisation_id)
    # there is a unique webhook per organisation for a given target_url, so returns a collection with 1 result max
    connection.get(
      "/api/v1/organisations/#{organisation_id}/webhook_endpoints", {
        target_url: "#{ENV['HOST']}/rdv_solidarites_webhooks"
      }
    )
  end

  def create_webhook_endpoint(organisation_id, subscriptions, trigger)
    connection.post("/api/v1/organisations/#{organisation_id}/webhook_endpoints", {
      target_url: "#{ENV['HOST']}/rdv_solidarites_webhooks",
      secret: ENV["RDV_SOLIDARITES_SECRET"],
      subscriptions: subscriptions,
      trigger: trigger
    }.to_json)
  end

  def update_webhook_endpoint(webhook_endpoint_id, organisation_id, subscriptions, trigger)
    connection.patch("/api/v1/organisations/#{organisation_id}/webhook_endpoints/#{webhook_endpoint_id}", {
      target_url: "#{ENV['HOST']}/rdv_solidarites_webhooks",
      secret: ENV["RDV_SOLIDARITES_SECRET"],
      subscriptions: subscriptions,
      trigger: trigger
    }.to_json)
  end

  def update_participation(participation_id, request_body = {})
    connection.patch("/api/v1/participations/#{participation_id}", request_body.to_json)
  end

  def create_motif_category(request_body)
    connection.post("/api/rdvinsertion/motif_categories", request_body.to_json)
  end

  def create_motif_category_territory(motif_category_short_name, organisation_id)
    connection.post("/api/rdvinsertion/motif_category_territories", {
      motif_category_short_name: motif_category_short_name,
      organisation_id: organisation_id
    }.to_json)
  end

  private

  def connection
    @connection ||= Faraday.new(url: ENV["RDV_SOLIDARITES_URL"]) do |f|
      f.headers = @auth_headers.merge("Content-Type" => "application/json")
      f.options.timeout = ENV.fetch("RDV_SOLIDARITES_TIMEOUT", 60).to_i
      f.options.open_timeout = ENV.fetch("RDV_SOLIDARITES_OPEN_TIMEOUT", 30).to_i

      f.adapter :net_http do |http|
        http.keep_alive_timeout = ENV.fetch("RDV_SOLIDARITES_KEEP_ALIVE_TIMEOUT", 30).to_i
      end
    end
  end
end
