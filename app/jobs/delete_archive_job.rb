class DeleteArchiveJob < ApplicationJob
  def perform(organisation_id, user_id)
    archive = Archive.find_by(organisation_id:, user_id:)
    archive&.destroy!
  end
end
