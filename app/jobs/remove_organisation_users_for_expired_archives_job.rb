class RemoveOrganisationUsersForExpiredArchivesJob < ApplicationJob
  def perform
    expired_archives.find_each do |archive|
      RemoveOrganisationUserForExpiredArchiveJob.perform_later(archive.id)
    end
    notify_on_mattermost
  end

  private

  def expired_archives
    Archive.where(created_at: ...2.years.ago)
  end

  def notify_on_mattermost
    MattermostClient.send_to_notif_channel(
      "🧹 #{expired_archives.count} usagers archivés il y a plus de 2 ans ont été retirés de leurs organisations"
    )
  end
end
