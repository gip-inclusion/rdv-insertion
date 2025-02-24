require "administrate/base_dashboard"

class BlockedUserDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    user: Field::BelongsTo,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    user
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [].freeze

  FORM_ATTRIBUTES = [].freeze

  def resource_name
    puts "DEBUG: resource_name method was called!"
    return "Blocked Users"
  end
end
