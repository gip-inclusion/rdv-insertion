class Department < ApplicationRecord
  validates_uniqueness_of :rdv_solidarites_organisation_id, allow_nil: true
  validates :name, :capital, :number, presence: true
  has_many :agents
end
