class AgentRole < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [:access_level].freeze

  belongs_to :agent
  belongs_to :organisation

  validates :rdv_solidarites_agent_role_id, uniqueness: true, allow_nil: true
  validates :agent, uniqueness: { scope: :organisation, message: "est déjà relié à l'organisation" }

  enum access_level: { basic: "basic", admin: "admin" }

  scope :with_export_authorization, -> { where(export_authorization: true) }
  scope :with_last_name, -> { joins(:agent).where.not(agents: { last_name: nil }) }

  before_save -> { self.export_authorization = true }, if: -> { admin? && export_authorization == false }
end
