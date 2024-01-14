require "administrate/base_dashboard"

class TemplateDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    custom_sentence: Field::Text,
    display_mandatory_warning: Field::Boolean,
    model: Field::Select.with_options(
      searchable: false, collection: ->(field) { field.resource.class.send(field.attribute.to_s.pluralize).keys }
    ),
    motif_categories: Field::HasMany,
    punishable_warning: Field::Text,
    rdv_purpose: Field::String,
    rdv_subject: Field::String,
    rdv_title: Field::String,
    rdv_title_by_phone: Field::String,
    user_designation: Field::String,
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
    rdv_subject
    rdv_title
    rdv_purpose
    model
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    model
    rdv_subject
    rdv_title
    rdv_purpose
    rdv_title_by_phone
    user_designation
    display_mandatory_warning
    punishable_warning
    custom_sentence
    motif_categories
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    custom_sentence
    display_mandatory_warning
    model
    motif_categories
    punishable_warning
    rdv_purpose
    rdv_subject
    rdv_title
    rdv_title_by_phone
    user_designation
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

  # Overwrite this method to customize how templates are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(template)
    "#{template.rdv_subject} - #{template.rdv_title}"
  end
end
