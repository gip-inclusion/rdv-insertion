class RgpdCleanupJob < ApplicationJob
  queue_as :whenever

  def perform
    Organisation.find_each do |organisation|
      RgpdCleanupOrganisationJob.perform_later(organisation.id)
    end
  end
end
