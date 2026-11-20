class Creneaux::RetrieveAndNotifyAllUnavailableCreneauxJob < ApplicationJob
  queue_as :whenever

  def perform
    Department.find_each do |departement|
      departement.organisations.active.with_rdv_solidarites_oauth_agent.distinct.find_each do |organisation|
        Creneaux::RetrieveAndNotifyUnavailableCreneauxJob.perform_later(organisation.id)
      end
    end
  end
end
