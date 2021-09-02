class Agent < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  has_and_belongs_to_many :departments

  delegate :rdv_solidarites_organisation_id, to: :department
end
