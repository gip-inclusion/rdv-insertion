# rubocop:disable Metrics/ClassLength
class UserListUpload::UserRow < ApplicationRecord
  include UserListUpload::UserRow::Status
  include UserListUpload::UserRow::MatchingUser

  USER_ATTRIBUTES = %i[
    email phone_number title first_name last_name affiliation_number nir birth_date department_internal_id
    france_travail_id role address
  ].freeze

  encrypts :nir

  before_save :format_attributes, :set_matching_user
  before_create :select_for_user_save!, if: :selected_by_default_for_user_save?
  after_commit :enqueue_save_user_job, if: :should_save_user_automatically?, on: :update

  belongs_to :user_list_upload
  belongs_to :matching_user, class_name: "User", optional: true
  has_many :user_save_attempts, class_name: "UserListUpload::UserSaveAttempt", dependent: :destroy
  has_many :invitation_attempts, class_name: "UserListUpload::InvitationAttempt", dependent: :destroy

  delegate :motif_category, :organisations, to: :user_list_upload, prefix: true
  delegate :department, :department_number, :department_id, :restricted_user_attributes, :department_level?,
           to: :user_list_upload
  delegate :valid?, :errors, to: :user, prefix: true
  delegate :no_organisation_to_assign?, to: :last_user_save_attempt, allow_nil: true

  squishes :first_name, :last_name, :affiliation_number, :department_internal_id, :address
  nullify_blank :first_name, :last_name, :affiliation_number, :department_internal_id, :address, :phone_number,
                :nir, :email, :referent_email, :organisation_search_terms

  EDITABLE_ATTRIBUTES = %i[title first_name last_name affiliation_number phone_number email].freeze

  def self.updatable_attributes
    column_names.map(&:to_sym) - %i[id created_at updated_at user_list_upload_id]
  end

  def user
    @user ||= (saved_user || matching_user || User.new(user_creation_origin_attributes)).tap do |user|
      user.assign_attributes(user_attributes)
      user.require_title_presence = true
    end
  end

  def saved_user
    user_save_attempts.last&.user
  end

  def matching_user_attribute_changed?(attribute)
    matching_user&.changed&.include?(attribute.to_s)
  end

  def attribute_changed_by_cnaf_data?(attribute)
    matching_user ? cnaf_data_changed_matching_user_attribute?(attribute) : cnaf_data_changed_row_attribute?(attribute)
  end

  def cnaf_data_changed_matching_user_attribute?(attribute)
    cnaf_data[attribute.to_s] && matching_user &&
      cnaf_data[attribute.to_s] != matching_user.attribute_in_database(attribute.to_s)
  end

  def cnaf_data_changed_row_attribute?(attribute)
    cnaf_data[attribute.to_s] && cnaf_data[attribute.to_s] != attributes[attribute.to_s]
  end

  def changed_by_cnaf_data?
    cnaf_data.keys.any? { |attribute| attribute_changed_by_cnaf_data?(attribute) }
  end

  def matching_user_id
    matching_user&.id
  end

  def matching_user_accessible?
    matching_user_id && matching_user.organisations.intersect?(user_list_upload.organisations)
  end

  def saved_user_id
    saved_user&.id
  end

  def user_id
    saved_user_id || matching_user_id
  end

  def user_persisted?
    user_id.present?
  end

  def tags
    (matching_user&.tags.to_a + Array(tags_to_assign)).uniq
  end

  def organisations
    (matching_user&.organisations.to_a + Array(organisation_to_assign)).uniq
  end

  def referents
    (matching_user&.referents.to_a + Array(referent_to_assign)).uniq
  end

  def motif_categories
    (matching_user&.motif_categories.to_a + Array(motif_category_to_assign)).uniq
  end

  def motif_category_to_assign
    user_list_upload_motif_category
  end

  def archives
    return [] if matching_user_id.blank?

    @archives ||=
      if organisation_to_assign
        Array(matching_user.archive_in_organisation(organisation_to_assign))
      else
        matching_user.archives.select do |archive|
          user_list_upload_organisations.map(&:id).include?(archive.organisation_id)
        end
      end
  end

  def archived?
    archives.any?
  end

  def archiving_reasons
    archives.map(&:archiving_reason)
  end

  def matching_follow_up
    return unless matching_user_id
    return unless motif_category_to_assign

    matching_user.follow_ups.find { |follow_up| follow_up.motif_category_id == motif_category_to_assign.id }
  end

  def matching_follow_up_closed?
    matching_follow_up&.closed?
  end

  def referent_to_assign
    return if referent_email.blank?

    user_list_upload.referents_from_rows.find { |referent| referent.email == referent_email }
  end

  def tags_to_assign
    return if tag_values.blank?

    user_list_upload.tags_from_rows.select { |tag| tag_values.include?(tag.value) }
  end

  def organisation_to_assign
    return user_list_upload.organisations.first if user_list_upload.organisations.length == 1

    if assigned_organisation_id.present?
      retrieve_organisation_by_id(assigned_organisation_id)
    elsif organisation_search_terms.present?
      retrieve_organisation_by_search_terms(organisation_search_terms)
    end
  end

  def association_already_persisted?(resource, association_name)
    matching_user&.send(association_name)&.include?(resource)
  end

  def will_change_matching_user?
    return false unless matching_user

    matching_user.changed? ||
      matching_user.organisations != organisations ||
      matching_user.motif_categories != motif_categories ||
      matching_user.referents != referents || matching_user.tags != tags
  end

  def select_for_user_save!
    self.selected_for_user_save = true
  end

  def save_user
    UserListUpload::UserSaveAttempt.create_from_row(user_row: self)
  end

  def attempted_user_save?
    user_save_attempts.any?
  end

  def last_user_save_attempt
    user_save_attempts.max_by(&:created_at)
  end

  def user_save_succeeded?
    last_user_save_attempt&.success?
  end

  def invitable?
    saved_user && user.can_be_invited_through_phone_or_email? && !invited_less_than_24_hours_ago?
  end

  def invited_less_than_24_hours_ago?
    previously_invited? && previously_invited_at > 24.hours.ago
  end

  def previously_invited?
    previous_invitations.any?
  end

  def previously_invited_at
    previous_invitations.max_by(&:created_at).created_at
  end

  def previous_invitations
    @previous_invitations ||= user.invitations.select do |invitation|
      # we don't consider the user as invited here if the invitation has not been sent by email or sms
      invitation.format.in?(%w[email sms]) && invitation.motif_category_id == user_list_upload.motif_category_id
    end
  end

  def invitable_by?(format)
    invitable? && user.can_be_invited_through?(format)
  end

  def invite_user_by(format)
    UserListUpload::InvitationAttempt.create_from_row(user_row: self, format:)
  end

  def invite_user
    invite_user_by("email") if invitable_by?("email")
    invite_user_by("sms") if invitable_by?("sms")
  end

  def invitation_attempted?
    invitation_attempts.any?
  end

  def last_invitation_attempt
    invitation_attempts.max_by(&:created_at)
  end

  def invitation_errors
    invitation_attempts.flat_map(&:service_errors)
  end

  def all_invitations_failed?
    invitation_attempted? && invitation_attempts.none?(&:success?)
  end

  # rubocop:disable Metrics/AbcSize
  def format_attributes
    # formatting attributes
    self.phone_number = PhoneNumberHelper.format_phone_number(phone_number) || phone_number
    self.nir = NirHelper.format_nir(nir) || nir
    self.title = User.titles.fetch(title.to_s.downcase, nil)
    self.role = User.roles.fetch(role.to_s.downcase, nil)
    self.tag_values = (tag_values.presence || []).map(&:squish)
    # formatting cnaf data
    self.cnaf_data = format_cnaf_data(cnaf_data) if cnaf_data.present?
    # we allow only the permitted attributes
    restricted_user_attributes.each { |attribute| send("#{attribute}=", nil) }
  end
  # rubocop:enable Metrics/AbcSize

  private

  def enqueue_save_user_job
    UserListUpload::SaveUserJob.perform_later(id)
  end

  def should_save_user_automatically?
    # automatic saves can only be triggered when a save has been attempted and when we change
    # some attributes
    attempted_user_save? && previous_changes.keys.any? do |attribute|
      (USER_ATTRIBUTES + [:assigned_organisation_id]).include?(attribute.to_sym)
    end
  end

  def user_attributes
    symbolized_attributes.compact_blank.merge(cnaf_data.symbolize_keys).slice(*USER_ATTRIBUTES)
  end

  def user_creation_origin_attributes
    {
      created_through: "rdv_insertion_upload_page",
      created_from_structure_type: user_list_upload.structure_type,
      created_from_structure_id: user_list_upload.structure_id
    }
  end

  def format_cnaf_data(cnaf_data)
    {
      "phone_number" => PhoneNumberHelper.format_phone_number(cnaf_data["phone_number"]),
      "email" => cnaf_data["email"],
      "rights_opening_date" => cnaf_data["rights_opening_date"]
    }.compact_blank.transform_values(&:squish)
  end

  def retrieve_organisation_by_id(organisation_id)
    user_list_upload.organisations.find { |organisation| organisation.id == organisation_id }
  end

  def retrieve_organisation_by_search_terms(search_terms)
    user_list_upload.organisations.find do |organisation|
      [organisation.name, organisation.slug].compact.map(&:downcase).any? do |attribute|
        search_terms.downcase.in?(attribute)
      end
    end
  end

  def selected_by_default_for_user_save?
    user_valid? && !archived? && !matching_follow_up_closed?
  end
end
# rubocop:enable Metrics/ClassLength
