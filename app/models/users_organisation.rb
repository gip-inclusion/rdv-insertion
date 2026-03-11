class UsersOrganisation < ApplicationRecord
  belongs_to :user
  belongs_to :organisation

  validates :user_id, uniqueness: { scope: :organisation_id }

  after_commit :delete_archive, on: :destroy
  after_commit :alert_if_user_added_to_another_department, on: :create

  private

  def delete_archive
    DeleteArchiveJob.perform_later(organisation_id, user_id)
  end

  def alert_if_user_added_to_another_department
    AlertUserAddedToAnotherDepartmentJob.perform_later(user_id, organisation_id)
  end
end
