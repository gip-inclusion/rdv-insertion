class SendCreneauAvailabilityAlertJob < ApplicationJob
  def perform
    Department.all.each do |departement|
      departement.organisations.each do |organisation|
        NotifyUnavailableCreneauJob.perform_async(organisation.id)
      end
    end
  end
end
