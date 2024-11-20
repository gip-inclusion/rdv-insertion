class ImportUserAssociationsFromRdvSolidaritesJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)
    # we take a super admin here but it could be any agent,
    # we will just need to be able to access the RDV-Solidarites API
    # to retrieve the associated ressources
    Agent.super_admins.first.with_rdv_solidarites_session do
      call_service!(Users::ImportAssociationsFromRdvSolidarites, user:)
    end
  end
end
