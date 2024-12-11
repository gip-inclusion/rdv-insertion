class DpaAgreement < ApplicationRecord
  belongs_to :organisation
  belongs_to :agent

  validates :organisation, uniqueness: true
end
