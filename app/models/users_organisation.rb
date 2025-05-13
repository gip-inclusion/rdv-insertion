class UsersOrganisation < ApplicationRecord
  belongs_to :user
  belongs_to :organisation

  validates :user_id, uniqueness: { scope: :organisation_id }
  validate :user_and_organisation_same_department, on: :create

  private

  def user_and_organisation_same_department
    return if user.department_id == organisation.department_id

    errors.add(:base, "Cet usager est affilié à un autre département")
  end
end
