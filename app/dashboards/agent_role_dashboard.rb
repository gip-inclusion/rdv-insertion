require "administrate/base_dashboard"

class AgentRoleDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    access_level: Field::Select.with_options(
      searchable: false, collection: ->(field) { field.resource.class.send(field.attribute.to_s.pluralize).keys }
    ),
    agent: Field::BelongsTo,
    last_webhook_update_received_at: Field::DateTime,
    organisation: Field::BelongsTo,
    rdv_solidarites_agent_role_id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    agent
    access_level
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    access_level
    agent
    last_webhook_update_received_at
    organisation
    rdv_solidarites_agent_role_id
    created_at
    updated_at
  ].freeze

  # Overwrite this method to customize how agent roles are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(agent_role)
  #   "AgentRole ##{agent_role.id}"
  # end
end
