class ImportUserAssociationsFromRdvSolidaritesJob < ApplicationJob
  def perform(user_id)
    @user = User.find(user_id)

    # RDV-Solidarités only lets an agent read a user they share an organisation with (Agent::UserPolicy)
    if oauth_agent_from_user_organisations
      oauth_agent_from_user_organisations.with_rdv_solidarites_session do
        call_service!(Users::ImportAssociationsFromRdvSolidarites, user: @user)
      end
    else
      Rails.logger.info(
        "Skipping associations import for user #{@user.id}: none of their organisations has an agent " \
        "with an RDV-Solidarités OAuth token"
      )
    end
  end

  private

  def oauth_agent_from_user_organisations
    @oauth_agent_from_user_organisations ||=
      Agent.with_rdv_solidarites_oauth_token.joins(:organisations).merge(@user.organisations.active).take
  end
end
