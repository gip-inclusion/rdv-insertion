class SendCreneauAvailabilityAlertJob < ApplicationJob
  def perform
    Department.find_each do |departement|
      departement.organisations.joins(:agents).distinct.find_each do |organisation|
        NotifyUnavailableCreneauJob.perform_later(organisation.id)
      end
    end
  end
end
