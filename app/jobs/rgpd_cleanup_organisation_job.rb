class RgpdCleanupOrganisationJob < ApplicationJob
  def perform(organisation_id)
    organisation = Organisation.find(organisation_id)
    Users::RgpdCleanupOrganisationService.call(organisation)
  end
end
