class RgpdCleanupOrganisationJob < ApplicationJob
  def perform(organisation_id)
    organisation = Organisation.find(organisation_id)
    call_service!(
      Organisations::RgpdCleanup, organisation: organisation, dry_run: ENV["RGDP_CLEANUP_DRY_RUN"] == "true"
    )
  end
end
