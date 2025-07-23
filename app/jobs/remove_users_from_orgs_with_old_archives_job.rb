class RemoveUsersFromOrgsWithOldArchivesJob < ApplicationJob
  def perform
    removed_users_count = 0

    Organisation.find_each do |organisation|
      @organisation = organisation
      @date_limit = organisation.data_retention_duration_in_months.months.ago

      archives_outside_retention_period.each do |archive|
        RemoveUserFromOrgWithOldArchiveJob.perform_later(archive.id)
        removed_users_count += 1
      end
    end

    notify_on_mattermost(removed_users_count) if removed_users_count.positive?
  end

  private

  def notify_on_mattermost(count)
    MattermostClient.send_to_notif_channel(
      "🧹 #{count} usagers archivés ont été retirés de leurs organisations selon leur durée de conservation"
    )
  end

  def archives_outside_retention_period
    Archive.joins(:organisation)
           .where(organisation: @organisation)
           .where(archives: { created_at: ...@date_limit })
           .reject { |archive| user_has_recent_rdvs?(archive.user) }
  end

  def user_has_recent_rdvs?(user)
    Participation.joins(:rdv)
                 .where(user: user)
                 .where(rdvs: { organisation: @organisation })
                 .exists?(participations: { created_at: @date_limit.. })
  end
end
