class Agent < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  belongs_to :department

  delegate :rdv_solidarites_organisation_id, to: :department
end
