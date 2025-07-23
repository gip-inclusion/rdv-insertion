class RgpdCleanupJob < ApplicationJob
  def perform
    Organisation.find_each do |organisation|
      RgpdCleanupOrganisationJob.perform_later(organisation.id)
    end
  end
end
