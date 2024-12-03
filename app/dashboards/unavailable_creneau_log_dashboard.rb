require "administrate/base_dashboard"

class UnavailableCreneauLogDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    number_of_invitations_affected: Field::Number,
    organisation: Field::BelongsTo,
    created_at: Field::Date,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    created_at
    organisation
    number_of_invitations_affected
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [].freeze

  FORM_ATTRIBUTES = %i[].freeze

  COLLECTION_FILTERS = {
    created_before: ->(resources, value) { resources.where("created_at <= ?", value) },
    created_after: ->(resources, value) { resources.where("created_at >= ?", value) }
  }.freeze

  def display_resource(unavailable_creneau_log)
    "de créneaux indisponibles pour l'organisation #{unavailable_creneau_log.organisation}"
  end
end
