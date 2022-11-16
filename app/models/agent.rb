class Agent < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [:email, :first_name, :last_name].freeze

  validates :email, presence: true, uniqueness: true
  validates :rdv_solidarites_agent_id, uniqueness: true, allow_nil: true

  has_and_belongs_to_many :organisations
  has_many :departments, through: :organisations
  has_many :configurations, through: :organisations

  def delete_organisation(organisation)
    organisations.delete(organisation)
    save!
  end
end
