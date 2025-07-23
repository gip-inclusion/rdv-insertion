require "administrate/base_dashboard"

class AgentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    agent_roles: Field::HasMany,
    agents_rdvs: Field::HasMany,
    category_configurations: Field::HasMany,
    departments: Field::HasMany,
    email: Field::String,
    first_name: Field::String,
    last_sign_in_at: Field::DateTime,
    last_name: Field::String,
    last_webhook_update_received_at: Field::DateTime,
    motif_categories: Field::HasMany,
    organisations: Field::HasMany,
    rdv_solidarites_agent_id: Field::Number,
    rdvs: Field::HasMany,
    referent_assignations: Field::HasMany,
    super_admin: Field::Boolean,
    users: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    first_name
    last_name
    email
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    first_name
    last_name
    email
    departments
    organisations
    agent_roles
    last_sign_in_at
    rdv_solidarites_agent_id
    super_admin
    created_at
    updated_at
  ].freeze

  # Overwrite this method to customize how agents are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(agent)
    agent.to_s
  end
end
