class UsersOrganisation < ApplicationRecord
  belongs_to :user
  belongs_to :organisation

  validates :user_id, uniqueness: { scope: :organisation_id }
end
