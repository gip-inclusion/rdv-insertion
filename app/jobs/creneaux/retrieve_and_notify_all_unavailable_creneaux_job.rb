class Creneaux::RetrieveAndNotifyAllUnavailableCreneauxJob < ApplicationJob
  def perform
    Department.find_each do |departement|
      departement.organisations.active.distinct.find_each do |organisation|
        Creneaux::RetrieveAndNotifyUnavailableCreneauxJob.perform_later(organisation.id)
      end
    end
  end
end
