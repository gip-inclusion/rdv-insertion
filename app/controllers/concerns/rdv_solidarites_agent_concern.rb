module RdvSolidaritesAgentConcern
  extend ActiveSupport::Concern

  def upsert_agent!
    return if upsert_agent.success?

    render json: { success: false, errors: upsert_agent.errors }, status: :unprocessable_entity
  end

  def upsert_agent
    @upsert_agent ||= UpsertAgent.call(
      email: request.headers["uid"], organisation_ids: retrieve_agent_organisations.organisations.map(&:id)
    )
  end

  def retrieve_agent_organisations!
    return if retrieve_agent_organisations.success?

    render json: { success: false, errors: retrieve_agent_organisations.errors }, status: :unprocessable_entity
  end

  def retrieve_agent_organisations
    @retrieve_agent_organisations ||= RdvSolidaritesApi::RetrieveOrganisations.call(
      rdv_solidarites_session: rdv_solidarites_session
    )
  end
end
