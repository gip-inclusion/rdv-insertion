class FindOrCreateAgent < BaseService
  def initialize(email:, organisation_ids:)
    @email = email
    @organisation_ids = organisation_ids
  end

  def call
    fail!("l'agent n'appartient pas à une organisation liée à un département") unless belongs_to_one_department?
    { agent: find_or_create_agent }
  end

  private

  def find_or_create_agent
    Agent.find_or_create_by(email: @email, department: agent_department)
  end

  def belongs_to_one_department?
    @organisation_ids.present? && agent_department.present?
  end

  def agent_department
    @agent_department ||= Department.includes(:agents)
                                    .where(rdv_solidarites_organisation_id: @organisation_ids)
                                    .first
  end
end
