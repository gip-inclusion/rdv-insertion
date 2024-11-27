require "administrate/base_dashboard"

class UnavailableCreneauLogDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    number_of_invitations_affected: Field::Number,
    organisation: Field::BelongsTo,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    number_of_invitations_affected
    organisation
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[number_of_invitations_affected organisation created_at]

  FORM_ATTRIBUTES = %i[]

  COLLECTION_FILTERS = {}.freeze

  def display_resource(unavailable_creneau_log)
    "de créneau indisponibles pour l'organisation #{unavailable_creneau_log.organisation}"
  end
end

