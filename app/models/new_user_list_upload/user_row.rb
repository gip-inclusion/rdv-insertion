# rubocop:disable Metrics/ClassLength
module NewUserListUpload
  class UserRow < ApplicationRecord
    self.table_name = "user_rows"

    include UserListUpload::RowStatus

    USER_ATTRIBUTES = %i[
      email phone_number title first_name last_name affiliation_number nir birth_date department_internal_id
      france_travail_id role address
    ].freeze

    attr_accessor :referent_to_assign, :organisation_to_assign, :tags_to_assign, :matching_user

    belongs_to :user_list_upload
    has_many :user_save_attempts, class_name: "NewUserListUpload::UserSaveAttempt", dependent: :destroy
    has_many :invitation_attempts, class_name: "NewUserListUpload::InvitationAttempt", dependent: :destroy

    delegate :motif_category, :motif_category_id, :department, :department_number, :organisations,
             to: :user_list_upload, prefix: true
    delegate :valid?, :errors, to: :user, prefix: true
    delegate :no_organisation_to_assign?, to: :last_user_save_attempt, allow_nil: true

    squishes(*updatable_attributes)

    EDITABLE_ATTRIBUTES = %i[title first_name last_name affiliation_number phone_number email].freeze

    def self.updatable_attributes
      column_names.map(&:to_sym) - %i[id created_at updated_at]
    end

    def user
      @user ||= (saved_user || matching_user || User.new(creation_origin_attributes)).tap do |user|
        user.assign_attributes(user_attributes)
      end
    end

    def saved_user
      user_save_attempts.last&.user
    end

    def matching_user_attribute_changed?(attribute)
      matching_user&.changed&.include?(attribute.to_s)
    end

    def attribute_changed_by_cnaf_data?(attribute)
      cnaf_data[attribute] && cnaf_data[attribute] != send(attribute)
    end

    def attribute_changed?(attribute)
      matching_user_attribute_changed?(attribute) || attribute_changed_by_cnaf_data?(attribute)
    end

    def changed_by_cnaf_data?
      cnaf_data.keys.any? { |attribute| attribute_changed_by_cnaf_data?(attribute) }
    end

    def matching_user_id
      matching_user&.id
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
      (matching_user&.motif_categories.to_a + Array(user_list_upload_motif_category)).uniq
    end

    def motif_category_to_assign
      user_list_upload_motif_category
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

    def post_code
      user.geocoded_post_code
    end

    def mark_for_user_save!
      self.marked_for_user_save = true
    end

    def save_user
      NewUserListUpload::UserSaveAttempt.create_from_row(user_row: self)
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
      self.marked_for_invitation = true
    end

    def invitable_by?(format)
      invitable? && user.can_be_invited_through?(format)
    end

    def invite(format)
      NewUserListUpload::InvitationAttempt.create_from_row(user_row: self, format:)
    end

    def invitation_attempted?
      invitation_attempts.any?
    end

    def invitation_errors
      invitation_attempts.flat_map(&:service_errors)
    end

    def all_invitations_failed?
      invitation_attempted? && invitation_attempts.none?(&:success?)
    end

    private

    def user_attributes
      symbolized_attributes.merge(cnaf_data.symbolize_keys).slice(*USER_ATTRIBUTES)
    end

    def creation_origin_attributes
      {
        created_through: "rdv_insertion_upload_page",
        created_from_structure_type: user_list_upload.structure_type,
        created_from_structure_id: user_list_upload.structure_id
      }
    end

    def format_attributes
      # formatting attributes
      self.phone_number = PhoneNumberHelper.format_phone_number(phone_number)
      self.nir = NirHelper.format_nir(nir)
      self.title = User.titles.fetch(title.to_s.downcase, nil)
      self.role = User.roles.fetch(role.to_s.downcase, nil)
      self.tags = (tags.presence || []).map(&:squish)
      # formatting cnaf data
      self.cnaf_data = format_cnaf_data(cnaf_data.presence || {})
      # we allow only the permitted attributes
      self.except!(*restricted_user_attributes.map(&:to_s))
    end
  end
end
# rubocop:enable Metrics/ClassLength
