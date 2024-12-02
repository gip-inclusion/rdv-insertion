class UserListUpload::Row
  attr_reader :uid, :user, :row_data

  include ActiveModel::Model
  include User::NirValidation
  include User::BirthDateValidation

  validates :first_name, :last_name, presence: true
  validates :email, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}\z/ },
                    allow_blank: true
  validates :phone_number, phone_number: true, allow_blank: true

  delegate :email, :phone_number, :title, :first_name, :last_name, :affiliation_number, :nir, :birth_date, to: :user

  def initialize(
    row_data:,
    matching_user: nil,
    referent_to_assign: nil,
    tags_to_assign: nil,
    organisation_to_assign: nil
  )
    @uid = row_data[:user_list_uid]
    @row_data = row_data
    @matching_user = matching_user
    @referent_to_assign = referent_to_assign
    @tags_to_assign = tags_to_assign
    @organisation_to_assign = organisation_to_assign
    @user = build_user
  end

  def status
    return :to_create unless @matching_user

    if @matching_user.changed?
      :to_update
    else
      :up_to_date
    end
  end

  def assign_data(data = {})
    @row_data.merge!(data.deep_symbolize_keys)
  end

  def cnaf_data
    @row_data[:cnaf_data] || {}
  end

  def user_attributes
    @row_data.merge(cnaf_data).slice(*User.attribute_names.map(&:to_sym))
  end

  def matching_user_attribute_changed?(attribute)
    @matching_user&.changed&.include?(attribute.to_s)
  end

  def attribute_changed_by_cnaf_data?(attribute)
    cnaf_data[attribute] && cnaf_data[attribute] != @row_data[attribute]
  end

  def attribute_changed?(attribute)
    matching_user_attribute_changed?(attribute) || attribute_changed_by_cnaf_data?(attribute)
  end

  def changed_by_cnaf_data?
    cnaf_data.keys.any? { |attribute| attribute_changed_by_cnaf_data?(attribute) }
  end

  def matching_user_id
    @matching_user&.id
  end

  private

  def build_user
    (@matching_user || User.new).tap do |user|
      user.assign_attributes(user_attributes)
    end
  end
end
