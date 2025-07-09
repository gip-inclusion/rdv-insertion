class RemoveOrganisationUsersForExpiredArchivesJob < ApplicationJob
  def perform
    expired_archives_count = 0

    Organisation.find_each do |organisation|
      date_limit = organisation.data_retention_duration.months.ago

      organisation_expired_archives = Archive.joins(:organisation)
                                             .where(organisation: organisation)
                                             .where(archives: { created_at: ...date_limit })

      organisation_expired_archives.find_each do |archive|
        RemoveOrganisationUserForExpiredArchiveJob.perform_later(archive.id)
        expired_archives_count += 1
      end
    end

    notify_on_mattermost(expired_archives_count) if expired_archives_count.positive?
  end

  private

  def notify_on_mattermost(count)
    MattermostClient.send_to_notif_channel(
      "🧹 #{count} usagers archivés ont été retirés de leurs organisations selon leur durée de conservation"
    )
  end
end
