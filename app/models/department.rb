class Department < ApplicationRecord
  validates_uniqueness_of :rdv_solidarites_organisation_id
end
