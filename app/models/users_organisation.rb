class UsersOrganisation < ApplicationRecord
  belongs_to :user
  belongs_to :organisation

  validates :user_id, uniqueness: { scope: :organisation_id }

  after_commit :delete_archive, on: :destroy

  private

  def delete_archive
    DeleteArchiveJob.perform_later(organisation_id, user_id)
  end
end
