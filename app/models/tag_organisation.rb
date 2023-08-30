class TagOrganisation < ApplicationRecord
  belongs_to :tag
  belongs_to :organisation
end
