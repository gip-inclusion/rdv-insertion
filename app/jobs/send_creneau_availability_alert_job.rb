class SendCreneauAvailabilityAlertJob < ApplicationJob
  def perform
    Department.find_each do |departement|
      departement.organisations.each do |organisation|
        NotifyUnavailableCreneauJob.perform_async(organisation.id)
      end
    end
  end
end
