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
    location_type: Field::Select.with_options(
      searchable: false, collection: ->(field) { field.resource.class.send(field.attribute.to_s.pluralize).keys }
    ),
    motif_category: Field::BelongsTo,
    name: Field::String,
    organisation: Field::BelongsTo,
    rdv_solidarites_motif_id: Field::Number,
    rdv_solidarites_service_id: Field::Number,
    rdvs: Field::HasMany,
    bookable_publicly: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    name
    collectif
    follow_up
    bookable_publicly
    organisation
  ].freeze

  # Overwrite this method to customize how motifs are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(motif)
  #   "Motif ##{motif.id}"
  # end
end
