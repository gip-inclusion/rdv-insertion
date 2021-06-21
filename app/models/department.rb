class Department < ApplicationRecord
  validates :rdv_solidarites_organisation_id, uniqueness: { allow_nil: true }
  validates :name, :capital, :number, presence: true
  has_many :agents
end
