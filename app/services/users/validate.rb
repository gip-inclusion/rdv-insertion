module Users
  class Validate < BaseService
    def initialize(user:, organisation: nil)
      @user = user
      @organisation = organisation
    end

    def call
      validate_identifier_is_present
      validate_uid_uniqueness_inside_department if @user.affiliation_number? && @user.role?
      validate_department_internal_id_uniqueness if @user.department_internal_id?
      validate_email_and_first_name_uniquess if @user.email?
      validate_phone_number_and_first_name_uniqueness if @user.phone_number_formatted.present?
    end

    private

    def validate_uid_uniqueness_inside_department
      return if users_with_same_uid.empty?

      result.errors << "Un usager avec le même numéro CAF et rôle se trouve au sein du département: " \
                       "#{users_with_same_uid.pluck(:id)}"
    end

    def validate_department_internal_id_uniqueness
      return if users_with_same_department_internal_id.empty?

      result.errors << "Un usager avec le même ID interne au département se trouve au sein du département: " \
                       "#{users_with_same_department_internal_id.pluck(:id)}"
    end

    def validate_email_and_first_name_uniquess
      return if @user.first_name.blank? || users_with_same_email_and_first_name.empty?

      result.errors << "Un usager avec le même email et même prénom est déjà enregistré: " \
                       "#{users_with_same_email_and_first_name.pluck(:id)}"
    end

    def validate_phone_number_and_first_name_uniqueness
      return if @user.first_name.blank? || users_with_same_phone_number_and_first_name.empty?

      result.errors << "Un usager avec le même numéro de téléphone et même prénom est déjà enregistré: " \
                       "#{users_with_same_phone_number_and_first_name.pluck(:id)}"
    end

    # this validation cannot be placed in the model because the record created from rdv-sp webhooks
    # doesn't match these rules: https://github.com/gip-inclusion/rdv-insertion/pull/1224
    def validate_identifier_is_present
      return if @user.nir? || @user.department_internal_id? || @user.email? || @user.phone_number?
      return if @user.affiliation_number? && @user.role?

      result.errors << "Il doit y avoir au moins un attribut permettant d'identifier la personne " \
                       "(NIR, email, numéro de tel, ID interne, numéro CAF/rôle)"
    end

    def users_from_same_departments
      @users_from_same_departments ||= User.active.joins(:organisations).where(
        organisations: { department_id: @user.department_ids.push(@organisation&.department_id).compact.uniq }
      )
    end

    def users_with_same_uid
      @users_with_same_uid ||=
        users_from_same_departments.where(
          affiliation_number: @user.affiliation_number, role: @user.role
        ) - [@user]
    end

    def users_with_same_department_internal_id
      @users_with_same_department_internal_id ||=
        users_from_same_departments.where(department_internal_id: @user.department_internal_id) - [@user]
    end

    def users_with_same_email_and_first_name
      @users_with_same_email_and_first_name ||=
        User.active.where(email: @user.email).select do |user|
          user.id != @user.id &&
            user.first_name.split.first.downcase == @user.first_name.split.first.downcase
        end
    end

    def users_with_same_phone_number_and_first_name
      @users_with_same_phone_number_and_first_name ||=
        User.active.where(phone_number: @user.phone_number_formatted).select do |user|
          user.id != @user.id &&
            user.first_name.split.first.downcase == @user.first_name.split.first.downcase
        end
    end
  end
end
