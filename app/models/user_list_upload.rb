class UserListUpload < ApplicationRecord
  include UserListUpload::Augmenter

  belongs_to :category_configuration, optional: true
  belongs_to :structure, polymorphic: true
  belongs_to :agent

  encrypts :user_list

  before_save :format_user_list!

  before_create :remove_duplicates!, :add_user_list_uid_to_users!, :augment_user_list!

  delegate :user_rows, :user_rows_enriched_with_cnaf_data, :update_rows, :update_row, :save_row_user,
           to: :user_collection
  delegate :motif_category, :motif_category_id, to: :category_configuration, allow_nil: true
  delegate :number, to: :department, prefix: true

  PERMITTED_ROW_ATTRIBUTES = %w[
    first_name last_name email phone_number role title nir department_internal_id
    france_travail_id rights_opening_date affiliation_number birth_date birth_name address
    organisation_search_terms referent_email tags user_list_uid matching_user_id cnaf_data
    saved_user_id marked_for_user_save marked_for_invitation assigned_organisation_id
    user_save_attempts invitation_attempts
  ].freeze

  def department
    structure_type == "Department" ? structure : structure.department
  end

  def matching_users
    @matching_users ||= User.active.where(id: user_list.pluck("matching_user_id"))
                            .preload(:organisations, :referents, :tags, :motif_categories, :address_geocoding)
                            .distinct
  end

  def referents_from_list
    @referents_from_list ||= Agent.where(email: user_list.pluck("referent_email")).distinct
  end

  def tags_from_list
    @tags_from_list ||= Tag.joins(:organisations)
                           .where(organisations:)
                           .where(value: user_list.pluck("tags").flatten)
                           .distinct
  end

  def saved_users
    @saved_users ||= User.joins(:organisations)
                         .where(organisations:)
                         .where(id: saved_user_ids)
                         .preload(:invitations, :address_geocoding, :invitations, :follow_ups)
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

  private

  def saved_user_ids
    @saved_user_ids ||= user_list.pluck("user_save_attempts").flatten.compact
                                 .pluck("user_id").compact
  end

  def add_user_list_uid_to_users!
    self.user_list = user_list.map do |user_attributes|
      user_attributes["user_list_uid"] = SecureRandom.uuid
      user_attributes
    end
  end

  # rubocop:disable Metrics/AbcSize
  def format_user_list!
    self.user_list = user_list.map do |user_attributes|
      # formatting attributes
      user_attributes["phone_number"] = PhoneNumberHelper.format_phone_number(user_attributes["phone_number"])
      user_attributes["nir"] = NirHelper.format_nir(user_attributes["nir"])
      user_attributes["title"] = User.titles.fetch(user_attributes["title"].to_s.downcase, nil)
      user_attributes["role"] = User.roles.fetch(user_attributes["role"].to_s.downcase, nil)
      user_attributes["tags"] = (user_attributes["tags"].presence || []).map(&:squish)
      # formatting cnaf data
      user_attributes["cnaf_data"] = format_cnaf_data(user_attributes["cnaf_data"].presence || {})
      # we allow only the permitted attributes
      user_attributes.slice!(*PERMITTED_ROW_ATTRIBUTES)
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

  def remove_duplicates!
    self.user_list = user_list.uniq
  end
end
