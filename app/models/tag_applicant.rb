class TagApplicant < ApplicationRecord
  belongs_to :tag
  belongs_to :applicant

  validates :tag_id, uniqueness: { scope: :applicant_id }
end
