module Applicants
  class Validate < BaseService
    def initialize(applicant:)
      @applicant = applicant
    end

    def call
      validate_identifier_is_present
      validate_uid_uniqueness_inside_department if @applicant.affiliation_number? && @applicant.role?
      validate_department_internal_id_uniqueness if @applicant.department_internal_id?
      validate_email_and_first_name_uniquess if @applicant.email?
      validate_phone_number_and_first_name_uniqueness if @applicant.phone_number?
    end

    private

    def validate_uid_uniqueness_inside_department
      return if applicants_with_same_uid.empty?

      result.errors << "Un allocataire avec le même numéro d'allocataire et rôle se trouve au sein du département: " \
                       "#{applicants_with_same_uid.pluck(:id)}"
    end

    def validate_department_internal_id_uniqueness
      return if applicants_with_same_department_internal_id.empty?

      result.errors << "Un allocataire avec le même ID interne au département se trouve au sein du département: " \
                       "#{applicants_with_same_department_internal_id.pluck(:id)}"
    end

    def validate_email_and_first_name_uniquess
      return if applicants_with_same_email_and_first_name.empty?

      result.errors << "Un allocataire avec le même email et même prénom est déjà enregistré: " \
                       "#{applicants_with_same_email_and_first_name.pluck(:id)}"
    end

    def validate_phone_number_and_first_name_uniqueness
      return if applicants_with_same_phone_number_and_first_name.empty?

      result.errors << "Un allocataire avec le même numéro de téléphone et même prénom est déjà enregistré: " \
                       "#{applicants_with_same_phone_number_and_first_name.pluck(:id)}"
    end

    def validate_identifier_is_present
      return if @applicant.nir? || @applicant.department_internal_id? || @applicant.email? || @applicant.phone_number?
      return if @applicant.affiliation_number? && @applicant.role?

      result.errors << "Il doit y avoir au moins un attribut permettant d'identifier la personne " \
                       "(NIR, email, numéro de tel, ID interne, numéro d'allocataire/rôle)"
    end

    def applicants_from_same_departments
      @applicants_from_same_departments ||= Applicant.active.joins(:organisations).where(
        organisations: { department_id: @applicant.department_ids }
      )
    end

    def applicants_with_same_uid
      @applicants_with_same_uid ||=
        applicants_from_same_departments.where(
          affiliation_number: @applicant.affiliation_number, role: @applicant.role
        ) - [@applicant]
    end

    def applicants_with_same_department_internal_id
      @applicants_with_same_department_internal_id ||=
        applicants_from_same_departments.where(department_internal_id: @applicant.department_internal_id) - [@applicant]
    end

    def applicants_with_same_email_and_first_name
      @applicants_with_same_email_and_first_name ||=
        Applicant.active.where(email: @applicant.email).select do |applicant|
          applicant.id != @applicant.id &&
            applicant.first_name.split.first.downcase == @applicant.first_name.split.first.downcase
        end
    end

    def applicants_with_same_phone_number_and_first_name
      @applicants_with_same_phone_number_and_first_name ||=
        Applicant.active.where(phone_number: @applicant.phone_number_formatted).select do |applicant|
          applicant.id != @applicant.id &&
            applicant.first_name.split.first.downcase == @applicant.first_name.split.first.downcase
        end
    end
  end
end
