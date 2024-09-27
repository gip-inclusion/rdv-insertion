class TagOrganisation < ApplicationRecord
  belongs_to :tag
  belongs_to :organisation

  validates :tag_id, uniqueness: { scope: :organisation_id }
end
