# rubocop:disable Metrics/ClassLength
class UserListUpload::Row
  include UserListUpload::RowStatus

  attr_reader :uid, :user, :row_data, :matching_user, :user_list_upload

  delegate :motif_category, :motif_category_id, :department, :department_number, :organisations,
           to: :user_list_upload, prefix: true
  delegate :email, :phone_number, :title, :first_name, :last_name, :affiliation_number, :nir, :birth_date,
           :department_internal_id, :france_travail_id, :role, :address, :full_name_stripped,
           :valid?, :errors,
           to: :user
  delegate :fetch, to: :row_data
  delegate :no_organisation_to_assign?, to: :last_user_save_attempt, allow_nil: true

  EDITABLE_ATTRIBUTES = %i[title first_name last_name affiliation_number phone_number email].freeze

  def initialize(row_data:, user_list_upload:, matching_user: nil, resources_to_assign: {})
    @uid = row_data[:user_list_uid]
    @row_data = row_data
    @user_list_upload = user_list_upload
    @matching_user = matching_user
    @resources_to_assign = resources_to_assign
    @user = build_user
  end

  def assign_data(data = {})
    @row_data.merge!(data.deep_symbolize_keys)
  end

  def cnaf_data
    @row_data[:cnaf_data] || {}
  end

  def user_attributes
    @row_data.merge(cnaf_data).merge(creation_origin_attributes).slice(*User.attribute_names.map(&:to_sym))
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

  def user_id
    saved_user_id || matching_user_id
  end

  def user_persisted?
    user_id.present?
  end

  def tags
    (@matching_user&.tags.to_a + Array(tags_to_assign)).uniq
  end

  def organisations
    (@matching_user&.organisations.to_a + Array(organisation_to_assign)).uniq
  end

  def referents
    (@matching_user&.referents.to_a + Array(referent_to_assign)).uniq
  end

  def motif_categories
    (@matching_user&.motif_categories.to_a + Array(user_list_upload_motif_category)).uniq
  end

  def association_already_persisted?(resource, association_name)
    @matching_user&.send(association_name)&.include?(resource)
  end

  def organisation_to_assign
    @resources_to_assign[:organisation]
  end

  def referent_to_assign
    @resources_to_assign[:referent]
  end

  def tags_to_assign
    @resources_to_assign[:tags]
  end

  def motif_category_to_assign
    user_list_upload_motif_category
  end

  def will_change_matching_user?
    return false unless matching_user

    matching_user.changed? ||
      matching_user.organisations != organisations ||
      matching_user.motif_categories != motif_categories ||
      matching_user.referents != referents || matching_user.tags != tags
  end

  def post_code
    user.geocoded_post_code
  end

  def mark_for_user_save!
    @row_data[:marked_for_user_save] = true
  end

  def marked_for_user_save?
    @row_data[:marked_for_user_save]
  end

  def save_user
    UserListUpload::UserSaveAttempt.create(user_row: self)
  end

  def user_save_attempts
    (@row_data[:user_save_attempts] || []).map do |user_save_attempt_attributes|
      UserListUpload::UserSaveAttempt.new(**user_save_attempt_attributes)
    end
  end

  def saved_user
    return unless saved_user_id

    @saved_user ||= user_list_upload.saved_users.find { |user| user.id == saved_user_id }
  end

  def attempted_user_save?
    user_save_attempts.any?
  end

  def last_user_save_attempt
    user_save_attempts.max_by(&:created_at)
  end

  def user_save_succeded?
    last_user_save_attempt&.success?
  end

  def saved_user_id
    last_user_save_attempt&.user_id
  end

  def department_number
    user_list_upload_department_number
  end

  def invitable?
    saved_user && user.can_be_invited_through_phone_or_email? && !previously_invited?
  end

  def previously_invited?
    previous_month_invitations.any?
  end

  def previously_invited_at
    previous_month_invitations.max_by(&:created_at).created_at
  end

  def previous_month_invitations
    user.invitations.select do |invitation|
      invitation.created_at > 1.month.ago &&
        # we don't consider the user as invited here if the invitation has not been sent by email or sms
        invitation.format.in?(%w[email sms]) && invitation.motif_category_id == user_list_upload.motif_category_id
    end
  end

  def mark_for_invitation!
    @row_data[:marked_for_invitation] = true
  end

  def marked_for_invitation?
    @row_data[:marked_for_invitation]
  end

  def invitable_by?(format)
    invitable? && user.can_be_invited_through?(format)
  end

  def invite(format)
    UserListUpload::InvitationAttempt.create(user_row: self, format:)
  end

  def invitation_attempts
    (@row_data[:invitation_attempts] || []).map do |invitation_attributes|
      UserListUpload::InvitationAttempt.new(**invitation_attributes)
    end
  end

  def invitation_attempted?
    invitation_attempts.any?
  end

  def invitation_errors
    invitation_attempts.flat_map(&:errors)
  end

  def all_invitations_failed?
    invitation_attempts.none?(&:success?)
  end

  def cache_args
    [
      uid,
      *UserListUpload::Row::EDITABLE_ATTRIBUTES.map { |attribute| send(attribute) },
      *user_save_attempts.map(&:created_at),
      *invitation_attempts.map(&:created_at)
    ]
  end

  private

  def build_user
    (saved_user || matching_user || User.new).tap do |user|
      user.assign_attributes(user_attributes)
    end
  end

  def creation_origin_attributes
    return {} if user_persisted?

    {
      created_through: "rdv_insertion_upload_page",
      created_from_structure_type: user_list_upload.structure_type,
      created_from_structure_id: user_list_upload.structure_id
    }
  end
end
# rubocop:enable Metrics/ClassLength
