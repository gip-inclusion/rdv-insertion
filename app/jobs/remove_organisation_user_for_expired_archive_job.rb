class RemoveOrganisationUserForExpiredArchiveJob < ApplicationJob
  def perform(archive_id)
    @archive = Archive.find(archive_id)
    @organisation = @archive.organisation
    @user = @archive.user

    return no_agent_found unless @organisation.agents.any?

    remove_user_from_organisation unless user_has_recent_activity_in_organisation?
  end

  private

  def no_agent_found
    Sentry.capture_message(
      "No agent found for organisation #{@organisation.id} when trying to remove user #{@user.id}"
    )
  end

  def remove_user_from_organisation
    @organisation.agents.first.with_rdv_solidarites_session do
      call_service!(
        Users::RemoveFromOrganisation,
        user: @user,
        organisation: @organisation
      )
    end
  end

  def user_has_recent_activity_in_organisation?
    Users::ActivityChecker.new(organisation: @organisation).user_has_recent_activity?(@user)
  end
end
