class Agent < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  has_and_belongs_to_many :organisations
  has_many :departments, through: :organisations
  has_many :applicants, through: :organisations
  has_many :configurations, through: :organisations

  delegate :rdv_solidarites_organisation_id, to: :organisation
end
