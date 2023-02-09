class AgentRole < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [:level].freeze

  LEVEL_BASIC = "basic".freeze
  LEVEL_ADMIN = "admin".freeze
  LEVELS = [LEVEL_BASIC, LEVEL_ADMIN].freeze

  belongs_to :agent
  belongs_to :organisation

  validates :level, inclusion: { in: LEVELS }
  validates :rdv_solidarites_agent_role_id, uniqueness: true, allow_nil: true
  validates :agent, uniqueness: { scope: :organisation, message: "est déjà relié à l'organisation" }

  accepts_nested_attributes_for :agent

  scope :level_basic, -> { where(level: LEVEL_BASIC) }
  scope :level_admin, -> { where(level: LEVEL_ADMIN) }

  def basic?
    level == LEVEL_BASIC
  end

  def admin?
    level == LEVEL_ADMIN
  end
end
