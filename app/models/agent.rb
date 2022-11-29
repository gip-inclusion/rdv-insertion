class Agent < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [:email, :first_name, :last_name].freeze

  validates :email, presence: true, uniqueness: true
  validates :rdv_solidarites_agent_id, uniqueness: true, allow_nil: true

  has_and_belongs_to_many :organisations
  has_and_belongs_to_many :applicants
  has_many :departments, through: :organisations
  has_many :configurations, through: :organisations

  scope :not_betagouv, -> { where.not("agents.email LIKE ?", "%beta.gouv.fr") }

  def delete_organisation(organisation)
    organisations.delete(organisation)
    save!
  end

  def to_s
    "#{first_name} #{last_name}"
  end
end
