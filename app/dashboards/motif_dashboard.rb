require "administrate/base_dashboard"

class MotifDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    collectif: Field::Boolean,
    deleted_at: Field::DateTime,
    follow_up: Field::Boolean,
    instruction_for_rdv: Field::Text,
    last_webhook_update_received_at: Field::DateTime,
    location_type: Field::Select.with_options(searchable: false, collection: ->(field) { field.resource.class.send(field.attribute.to_s.pluralize).keys }),
    motif_category: Field::BelongsTo,
    name: Field::String,
    organisation: Field::BelongsTo,
    rdv_solidarites_motif_id: Field::Number,
    rdv_solidarites_service_id: Field::Number,
    rdvs: Field::HasMany,
    reservable_online: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    collectif
    deleted_at
    follow_up
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    collectif
    deleted_at
    follow_up
    instruction_for_rdv
    last_webhook_update_received_at
    location_type
    motif_category
    name
    organisation
    rdv_solidarites_motif_id
    rdv_solidarites_service_id
    rdvs
    reservable_online
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    collectif
    deleted_at
    follow_up
    instruction_for_rdv
    last_webhook_update_received_at
    location_type
    motif_category
    name
    organisation
    rdv_solidarites_motif_id
    rdv_solidarites_service_id
    rdvs
    reservable_online
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how motifs are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(motif)
  #   "Motif ##{motif.id}"
  # end
end
