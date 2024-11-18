require "administrate/base_dashboard"

class WebhookEndpointDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    url: Field::String,
    organisation: Field::BelongsTo,
    subscriptions: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  SHOW_PAGE_ATTRIBUTES = [].freeze

  COLLECTION_ATTRIBUTES = [
    :organisation,
    :url,
    :subscriptions,
    :created_at
  ].freeze
end
