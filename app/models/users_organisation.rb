class UsersOrganisation < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :organisation

  validates :user_id, uniqueness: { scope: :organisation_id }
  validate :user_and_organisation_in_same_department

  after_commit :delete_archive, on: :destroy

  private

  def user_and_organisation_in_same_department
    return if user.department_id == organisation.department_id

    errors.add(:base, "L'usager et l'organisation ne sont pas dans le même département")
  end

  def delete_archive
    DeleteArchiveJob.perform_later(organisation_id, user_id)
  end
end
