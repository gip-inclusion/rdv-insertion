
require "administrate/base_dashboard"

class LieuDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    address: Field::String,
    last_webhook_update_received_at: Field::DateTime,
    name: Field::String,
    organisation: Field::BelongsTo,
    phone_number: Field::String,
    rdv_solidarites_lieu_id: Field::Number,
    rdvs: Field::HasMany,
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
    address
    phone_number
  ].freeze

  # Overwrite this method to customize how lieux are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(lieu)
  #   "Lieu ##{lieu.id}"
  # end
end
