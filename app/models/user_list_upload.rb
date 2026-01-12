class UserListUpload < ApplicationRecord
  include UserListUpload::Metrics
  include UserListUpload::Navigation

  STEPS_BY_ORIGIN = {
    file_upload: %i[user_save invitation],
    invite_all_uninvited_button: %i[invitation]
  }.freeze

  belongs_to :category_configuration, optional: true
  belongs_to :structure, polymorphic: true
  belongs_to :agent

  has_many :user_rows, class_name: "UserListUpload::UserRow", dependent: :destroy
  has_many :processing_logs, class_name: "UserListUpload::ProcessingLog", dependent: :destroy
  has_many :user_save_attempts, class_name: "UserListUpload::UserSaveAttempt", through: :user_rows
  has_many :invitation_attempts, class_name: "UserListUpload::InvitationAttempt", through: :user_rows

  enum :origin, { file_upload: "file_upload", invite_all_uninvited_button: "invite_all_uninvited_button" },
       prefix: true

  validates :category_configuration_id, presence: true, if: :handle_invitation_only?

  accepts_nested_attributes_for :user_rows

  delegate :user_rows_enriched_with_cnaf_data, :update_rows, :user_rows_selected_for_invitation,
           :user_rows_selected_for_user_save, :user_rows_with_errors, :user_rows_archived,
           :user_rows_with_closed_follow_up, :user_rows_with_user_save_success, :user_rows_with_successful_invitation,
           to: :user_collection
  delegate :motif_category, :motif_category_id, :motif_category_name, :motif_category_short_name,
           to: :category_configuration, allow_nil: true
  delegate :number, :id, to: :department, prefix: true

  def save_with_existing_users!(users)
    transaction do
      save!
      UserListUpload::UserRow.import_from_users!(users, user_list_upload: self)
    end
  end

  def department
    department_level? ? structure : structure.department
  end

  def department_level?
    structure_type == "Department"
  end

  def organisation
    structure if structure_type == "Organisation"
  end

  def referents_from_rows
    @referents_from_rows ||= Agent.joins(:organisations)
                                  .where(organisations:)
                                  .where(email: user_rows.pluck("referent_email"))
                                  .distinct
  end

  def tags_from_rows
    @tags_from_rows ||= Tag.joins(:organisations)
                           .where(organisations:)
                           .where(value: user_rows.pluck("tag_values").flatten)
                           .distinct
  end

  def user_collection
    UserListUpload::Collection.new(user_list_upload: self)
  end

  def organisations
    structure_organisations & agent.organisations
  end

  def structure_organisations
    department_level? ? structure.organisations : [structure]
  end

  def invitations_enabled? = category_configuration.present?

  def restricted_user_attributes
    UserPolicy.restricted_user_attributes_for_organisations(organisations:).to_a
  end

  def user_rows_attributes=(attributes)
    attributes = remove_duplicates!(attributes)
    super
  end

  def potential_matching_users_in_all_app
    @potential_matching_users_in_all_app ||=
      User.active.where(email: user_row_attributes.pluck("email").compact)
          .or(
            User.active.where(phone_number: user_row_attributes_formatted_phone_numbers)
          )
          .or(User.active.where(nir: user_row_attributes_formatted_nirs))
          # Preload associations to avoid N+1 queries when calling user_row.user_valid?
          .preload(*user_associations_to_preload)
  end

  def potential_matching_users_in_department
    @potential_matching_users_in_department ||= User.active.joins(:organisations).where(
      affiliation_number: user_row_attributes.pluck("affiliation_number").compact,
      organisations: { department_id: department.id }
    ).or(
      User.active.joins(:organisations).where(
        department_internal_id: user_row_attributes.pluck("department_internal_id").compact,
        organisations: { department_id: department.id }
      )
      # Preload associations to avoid N+1 queries when calling user_row.user_valid?
    ).preload(*user_associations_to_preload)
  end

  def handle_user_save? = STEPS_BY_ORIGIN[origin.to_sym].include?(:user_save)
  def handle_invitation_only? = STEPS_BY_ORIGIN[origin.to_sym] == [:invitation]

  def user_associations_to_preload
    # we need to preload the associations to avoid N+1 queries when calling user_row.user_valid?
    # or user_row.invitable?
    if handle_user_save?
      [:archives, :follow_ups]
    else
      [invitations: :follow_up]
    end
  end

  private

  def user_row_attributes
    @user_row_attributes ||= user_rows.map(&:attributes)
  end

  def user_row_attributes_formatted_phone_numbers
    @user_row_attributes_formatted_phone_numbers ||=
      user_row_attributes.pluck("phone_number").compact.map do |phone_number|
        PhoneNumberHelper.format_phone_number(phone_number)
      end
  end

  def user_row_attributes_formatted_nirs
    @user_row_attributes_formatted_nirs ||=
      user_row_attributes.pluck("nir").compact.map do |nir|
        NirHelper.format_nir(nir)
      end
  end

  def remove_duplicates!(attributes)
    attributes.uniq
  end
end
