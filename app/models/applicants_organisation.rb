class ApplicantsOrganisation < ApplicationRecord
  belongs_to :applicant
  belongs_to :organisation

  validates :applicant_id, uniqueness: { scope: :organisation_id }
end
