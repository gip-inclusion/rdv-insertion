class SendCreneauAvailabilityAlertJob < ApplicationJob
  def perform
    Department.find_each do |departement|
      departement.organisations.active.distinct.find_each do |organisation|
        NotifyUnavailableCreneauJob.perform_later(organisation.id)
      end
    end
  end
end
