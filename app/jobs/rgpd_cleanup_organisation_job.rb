class RgpdCleanupOrganisationJob < ApplicationJob
  def perform(organisation_id)
    organisation = Organisation.find(organisation_id)
    Organisations::RgpdCleanup.call(organisation: organisation)
  end
end
