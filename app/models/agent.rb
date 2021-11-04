class Agent < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  has_and_belongs_to_many :organisations

  delegate :rdv_solidarites_organisation_id, to: :organisation
end
