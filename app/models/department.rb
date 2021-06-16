class Department < ApplicationRecord
  validates_uniqueness_of :rdv_solidarites_organisation_id, allow_blank: true
  has_many :agents
end
