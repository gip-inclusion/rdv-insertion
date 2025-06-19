module AgentsHelper
  def agents_index_url(organisation)
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{organisation.rdv_solidarites_organisation_id}/agents"
  end

  def add_agent_url(organisation)
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{organisation.rdv_solidarites_organisation_id}/agents/new"
  end
end
