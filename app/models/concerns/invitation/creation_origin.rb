module Invitation::CreationOrigin
  extend ActiveSupport::Concern

  SYSTEM_ORIGINS = %w[reminder legacy_triggered_by_periodic_job].freeze

  included do
    belongs_to :created_by_agent, class_name: "Agent", optional: true

    enum :origin, {
      # Triggered by an agent
      user_list_upload: "user_list_upload",
      users_index_page: "users_index_page",
      user_follow_ups_page: "user_follow_ups_page",
      api: "api",
      # Generated automatically by the system
      reminder: "reminder",
      # Legacy — never assigned at runtime
      # We used to trigger some invitations by a CRON periodically. Feature has been removed.
      legacy_triggered_by_periodic_job: "legacy_triggered_by_periodic_job",
      # We used to track who triggered the invitation but without details the action that triggered it
      legacy_triggered_by_agent: "legacy_triggered_by_agent"
    }

    validates :origin, presence: true

    attr_readonly :origin, :created_by_agent_id

    scope :agent_initiated, -> { where.not(origin: SYSTEM_ORIGINS) }
  end

  def system_generated? = origin.in?(SYSTEM_ORIGINS)

  def agent_initiated? = !system_generated?
end
