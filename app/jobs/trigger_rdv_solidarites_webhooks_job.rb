class TriggerRdvSolidaritesWebhooksJob < ApplicationJob
  def perform(
    rdv_solidarites_webhook_endpoint_id, rdv_solidarites_organisation_id, agent_email
  )
    @rdv_solidarites_webhook_endpoint_id = rdv_solidarites_webhook_endpoint_id
    @rdv_solidarites_organisation_id = rdv_solidarites_organisation_id
    @agent_email = agent_email

    set_current_agent(@agent_email)
    return if trigger_webhook_endpoint.success?

    raise StandardError, trigger_webhook_endpoint.errors.join(" - ")
  end

  private

  def trigger_webhook_endpoint
    @trigger_webhook_endpoint ||= RdvSolidaritesApi::UpdateWebhookEndpoint.call(
      rdv_solidarites_webhook_endpoint_id: @rdv_solidarites_webhook_endpoint_id,
      rdv_solidarites_organisation_id: @rdv_solidarites_organisation_id,
      trigger: true
    )
  end
end
