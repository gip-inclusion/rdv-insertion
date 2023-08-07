class TagApplicant < ApplicationRecord
  belongs_to :tag
  belongs_to :applicant
end
