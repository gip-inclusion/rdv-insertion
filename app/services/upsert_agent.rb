class UpsertAgent < BaseService
  def initialize(email:, organisation_ids:)
    @email = email
    @organisation_ids = organisation_ids
  end

  def call
    result.agent = Agent.find_or_create_by(email: @email)
    update_agent_if_changed
  end

  private

  def update_agent_if_changed
    agent = result.agent
    agent.organisations = agent_organisations
    agent.save! if agent.changed?
  end

  def agent_organisations
    @agent_organisations ||= Organisation.includes(:agents)
                                         .where(rdv_solidarites_organisation_id: @organisation_ids)
  end
end
