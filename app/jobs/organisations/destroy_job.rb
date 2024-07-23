class Organisations::DestroyJob < ApplicationJob
  def perform(organisation_id)
    organisation = Organisation.find(organisation_id)

    organisation.lieux.destroy_all
    organisation.motifs.destroy_all
    organisation.agent_roles.destroy_all
    organisation.category_configurations.destroy_all
    organisation.destroy!
  end
end
