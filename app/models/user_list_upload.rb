class UserListUpload < ApplicationRecord
  include UserListUpload::Augmenter

  belongs_to :category_configuration, optional: true
  belongs_to :structure, polymorphic: true
  belongs_to :agent

  encrypts :user_list

  before_save :format_user_list!

  before_create :add_user_list_uid_to_users!, :augment_user_list!

  delegate :user_rows, :user_rows_enriched_with_cnaf_data, :update_rows, :update_row, to: :user_collection
  delegate :motif_category, to: :category_configuration, allow_nil: true

  def department
    structure_type == "Department" ? structure : structure.department
  end

  def matching_users
    @matching_users ||= User.joins(:organisations)
                            .where(organisations:)
                            .where(id: user_list.pluck("matching_user_id"))
                            .preload(:organisations, :referents, :tags, follow_ups: :motif_category)
                            .distinct
  end

  def referents_from_list
    @referents_from_list ||= Agent.where(email: user_list.pluck("referent_email")).distinct
  end

  def tags_from_list
    @tags_from_list ||= Tag.joins(:organisations)
                           .where(organisations:)
                           .where(name: user_list.pluck("tags").flatten)
                           .distinct
  end

  def user_collection
    @user_collection ||= UserListUpload::Collection.new(
      user_list_upload: self,
      matching_users:,
      referents_from_list:,
      tags_from_list:,
      organisations:
    )
  end

  def organisations
    structure_organisations & agent.organisations
  end

  def structure_organisations
    structure_type == "Department" ? structure.organisations : [structure]
  end

  private

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
      user_attributes["tags"] = user_attributes["tags"].map(&:squish) if user_attributes["tags"].present?
      # formatting cnaf data
      if user_attributes["cnaf_data"].present?
        user_attributes["cnaf_data"] = format_cnaf_data(user_attributes["cnaf_data"])
      end
      # we remove restricted attributes
      user_attributes.except!(*restricted_user_attributes)
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

  def restricted_user_attributes
    UserPolicy.agent_restricted_user_attributes(agent:).map(&:to_s)
  end
end
