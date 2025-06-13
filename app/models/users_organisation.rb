class UsersOrganisation < ApplicationRecord
  belongs_to :user
  belongs_to :organisation

  validates :user_id, uniqueness: { scope: :organisation_id }
  validate :user_and_organisation_same_department, on: :create

  after_commit :delete_archive, on: :destroy

  private

  def user_and_organisation_same_department
    return if user.department_id == organisation.department_id

    errors.add(:base, "Cet usager est affilié à un autre département")
  end

  def delete_archive
    DeleteArchiveJob.perform_later(organisation_id, user_id)
  end
end
