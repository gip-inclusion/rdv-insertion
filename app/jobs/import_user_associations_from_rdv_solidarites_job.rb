class ImportUserAssociationsFromRdvSolidaritesJob < ApplicationJob
  def perform(user_id)
    @user = User.find(user_id)

    # we just need an agent that has a common organisation with the user here.
    # It is necessary since in RDV-Solidarites we check the Agent::UserPolicy on the user when
    # retrieving the user. This policy is based on mutual organisation between the agent and the user.
    random_agent_from_user_organisations.with_rdv_solidarites_session do
      call_service!(Users::ImportAssociationsFromRdvSolidarites, user: @user)
    end
  end

  private

  def random_agent_from_user_organisations
    Agent.joins(:organisations).merge(@user.organisations.active).with_last_name.take
  end
end
