module Applicants
  class ProcessInput < BaseService
    def initialize(applicant_params:, department_id:)
      @applicant_params = applicant_params.deep_symbolize_keys
      @department_id = department_id
    end

    def call
      result.matching_applicant = find_matching_applicant
      check_for_contact_duplicates! unless result.matching_applicant
      verify_nir_matches! if result.matching_applicant
    end

    private

    def check_for_contact_duplicates!
      return unless find_contact_duplicate.contact_duplicate

      result.contact_duplicate = find_contact_duplicate.contact_duplicate
      result.duplicate_attribute = find_contact_duplicate.duplicate_attribute
      fail!(
        "Un utilisateur avec le même " \
        "#{I18n.t("activerecord.attributes.applicant.#{result.duplicate_attribute}").downcase} " \
        "mais avec un prénom différent a été retrouvé. S'il s'agit d'un conjoint, veuillez le préciser sous " \
        "l'attribut 'rôle'"
      )
    end

    def find_contact_duplicate
      @find_contact_duplicate ||= Applicants::FindContactDuplicate.call(
        email: @applicant_params[:email], phone_number: @applicant_params[:phone_number],
        role: @applicant_params[:role], first_name: @applicant_params[:first_name]
      )
    end

    def verify_nir_matches!
      return if nir_matches?

      fail!("La personne #{result.matching_applicant.id} correspond mais n'a pas le même NIR")
    end

    def find_matching_applicant
      find_by_encrypted_id ||
        find_applicant_by_nir ||
        find_applicant_by_department_internal_id ||
        find_applicant_by_role_and_affiliation_number ||
        find_applicant_by_email ||
        find_applicant_by_phone_number
    end

    def find_by_encrypted_id
      return if @applicant_params[:encrypted_id].blank?

      Applicant.active.find_by(id: EncryptionHelper.decrypt(@applicant_params[:encrypted_id]))
    end

    def find_applicant_by_nir
      return if formatted_nir_attribute.blank?

      Applicant.active.find_by(nir: formatted_nir_attribute)
    end

    def find_applicant_by_department_internal_id
      return if @applicant_params[:department_internal_id].blank?

      Applicant.joins(:organisations).where(
        department_internal_id: @applicant_params[:department_internal_id],
        organisations: { department_id: @department_id }
      ).first
    end

    def find_applicant_by_email
      return if @applicant_params[:email].blank? || @applicant_params[:first_name].blank?

      Applicant.active.where(email: @applicant_params[:email]).find do |applicant|
        applicant.first_name.split.first.downcase == @applicant_params[:first_name].split.first.downcase
      end
    end

    def find_applicant_by_phone_number
      return if phone_number_formatted.blank? || @applicant_params[:first_name].blank?

      Applicant.active.where(phone_number: phone_number_formatted).find do |applicant|
        applicant.first_name.split.first.downcase == @applicant_params[:first_name].split.first.downcase
      end
    end

    def find_applicant_by_role_and_affiliation_number
      return if @applicant_params[:role].blank? || @applicant_params[:affiliation_number].blank?

      Applicant.active.joins(:organisations).where(
        affiliation_number: @applicant_params[:affiliation_number],
        role: @applicant_params[:role], organisations: { department_id: @department_id }
      ).first
    end

    def phone_number_formatted
      PhoneNumberHelper.format_phone_number(@applicant_params[:phone_number])
    end

    def formatted_nir_attribute
      NirHelper.format_nir(@applicant_params[:nir])
    end

    def nir_matches?
      formatted_nir_attribute.blank? || result.matching_applicant.nir.blank? ||
        formatted_nir_attribute == result.matching_applicant.nir
    end
  end
end
