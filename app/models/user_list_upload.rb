# rubocop:disable Metrics/ClassLength
class UserListUpload < ApplicationRecord
  include UserListUpload::Augmenter

  belongs_to :category_configuration, optional: true
  belongs_to :structure, polymorphic: true
  belongs_to :agent

  has_many :user_rows, class_name: "::NewUserListUpload::UserRow", dependent: :destroy
  has_many :user_save_attempts, class_name: "::NewUserListUpload::UserSaveAttempt", through: :user_rows

  accepts_nested_attributes_for :user_rows

  delegate :user_rows_enriched_with_cnaf_data, :update_rows, :update_row, :save_row_user,
           to: :user_collection
  delegate :motif_category, :motif_category_id, to: :category_configuration, allow_nil: true
  delegate :number, to: :department, prefix: true

  def department
    structure_type == "Department" ? structure : structure.department
  end

  def matching_users
    @matching_users ||= User.active.where(id: user_rows.pluck("matching_user_id"))
                            .preload(:organisations, :referents, :tags, :motif_categories, :address_geocoding)
                            .distinct
  end

  def referents_from_list
    @referents_from_list ||= Agent.where(email: user_rows.pluck("referent_email")).distinct
  end

  def tags_from_list
    @tags_from_list ||= Tag.joins(:organisations)
                           .where(organisations:)
                           .where(value: user_rows.pluck("tags").flatten)
                           .distinct
  end

  def user_collection
    UserListUpload::Collection.new(user_list_upload: self)
  end

  def organisations
    structure_organisations & agent.organisations
  end

  def structure_organisations
    structure_type == "Department" ? structure.organisations : [structure]
  end

  def invitations_enabled? = category_configuration.present?

  def structure_user_path(user_id)
    if structure_type == "Department"
      Rails.application.routes.url_helpers.department_user_path(id: user_id, department_id: structure_id)
    else
      Rails.application.routes.url_helpers.organisation_user_path(id: user_id, organisation_id: structure_id)
    end
  end

  def structure_users_path
    if structure_type == "Department"
      Rails.application.routes.url_helpers.department_users_path(department_id: structure_id)
    else
      Rails.application.routes.url_helpers.organisation_users_path(organisation_id: structure_id)
    end
  end

  def user_invitations_path(user_id, **)
    if structure_type == "Department"
      Rails.application.routes.url_helpers.department_user_invitations_path(department_id: structure_id, user_id:, **)
    else
      Rails.application.routes.url_helpers.organisation_user_invitations_path(
        organisation_id: structure_id, user_id:, **
      )
    end
  end

  def restricted_user_attributes
    UserPolicy.restricted_user_attributes_for_organisations(organisations:).to_a
  end

  def user_rows_attributes=(attributes)
    attributes = format_user_list!(attributes)
    attributes = remove_duplicates!(attributes)
    attributes = add_user_list_uid_to_users!(attributes)
    attributes = augment_user_list!(attributes)
    super(attributes)
  end

  private

  def add_user_list_uid_to_users!(attributes)
    attributes.map do |user_attributes|
      user_attributes["uid"] = SecureRandom.uuid
      user_attributes
    end
  end

  # rubocop:disable Metrics/AbcSize
  def format_user_list!(attributes)
    attributes.map do |user_attributes|
      # formatting attributes
      user_attributes["phone_number"] = PhoneNumberHelper.format_phone_number(user_attributes["phone_number"])
      user_attributes["nir"] = NirHelper.format_nir(user_attributes["nir"])
      user_attributes["title"] = User.titles.fetch(user_attributes["title"].to_s.downcase, nil)
      user_attributes["role"] = User.roles.fetch(user_attributes["role"].to_s.downcase, nil)
      user_attributes["tags"] = (user_attributes["tags"].presence || []).map(&:squish)
      # formatting cnaf data
      user_attributes["cnaf_data"] = format_cnaf_data(user_attributes["cnaf_data"].presence || {})
      # we allow only the permitted attributes
      user_attributes.except!(*restricted_user_attributes.map(&:to_s))
      # we remove blank attributes
      user_attributes.compact_blank!
      # we remove line breaks in strings and extra spaces
      user_attributes.transform_values! { |value| value.is_a?(String) ? value.squish : value }
    end
  end
  # rubocop:enable Metrics/AbcSize

  def format_cnaf_data(cnaf_data)
    {
      "phone_number" => PhoneNumberHelper.format_phone_number(cnaf_data["phone_number"]),
      "email" => cnaf_data["email"],
      "rights_opening_date" => cnaf_data["rights_opening_date"]
    }.compact_blank.transform_values(&:squish)
  end

  def remove_duplicates!(attributes)
    attributes.uniq
  end
end
# rubocop:enable Metrics/ClassLength
