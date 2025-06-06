class UserListUpload < ApplicationRecord
  belongs_to :category_configuration, optional: true
  belongs_to :structure, polymorphic: true
  belongs_to :agent

  has_many :user_rows, class_name: "UserListUpload::UserRow", dependent: :destroy
  has_many :user_save_attempts, class_name: "UserListUpload::UserSaveAttempt", through: :user_rows
  has_many :invitation_attempts, class_name: "UserListUpload::InvitationAttempt", through: :user_rows

  accepts_nested_attributes_for :user_rows

  delegate :user_rows_enriched_with_cnaf_data, :update_rows, :user_rows_selected_for_invitation,
           :user_rows_selected_for_user_save, :user_rows_with_errors, :user_rows_archived,
           :user_rows_with_closed_follow_up, to: :user_collection
  delegate :motif_category, :motif_category_id, to: :category_configuration, allow_nil: true
  delegate :number, to: :department, prefix: true

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

  def structure_user_path(user_id)
    if department_level?
      Rails.application.routes.url_helpers.department_user_path(id: user_id, department_id: structure_id)
    else
      Rails.application.routes.url_helpers.organisation_user_path(id: user_id, organisation_id: structure_id)
    end
  end

  def structure_users_path
    if department_level?
      Rails.application.routes.url_helpers.department_users_path(department_id: structure_id)
    else
      Rails.application.routes.url_helpers.organisation_users_path(organisation_id: structure_id)
    end
  end

  def user_invitations_path(user_id, **)
    if department_level?
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
          .select(:id, :nir, :phone_number, :email, :first_name)
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
    ).select(:id, :department_internal_id, :affiliation_number, :role)
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
