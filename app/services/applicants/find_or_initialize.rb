module Applicants
  class FindOrInitialize < BaseService
    def initialize(applicant_attributes:, department_id:)
      @attributes = applicant_attributes.deep_symbolize_keys
      @department_id = department_id
    end

    def call
      result.applicant = find_or_initialize_applicant
    end

    private

    def find_or_initialize_applicant
      find_applicant_by_nir ||
        find_applicant_by_department_internal_id ||
        find_applicant_by_role_and_affiliation_number ||
        find_applicant_by_email ||
        find_applicant_by_phone_number ||
        Applicant.new
    end

    def find_applicant_by_nir
      return if @attributes[:nir].blank?

      Applicant.active.find_by(nir: @attributes[:nir])
    end

    def find_applicant_by_department_internal_id
      return if @attributes[:department_internal_id].blank?

      Applicant.active.joins(:organisations).where(
        department_internal_id: @attributes[:department_internal_id], organisations: { department_id: @department_id }
      ).first
    end

    def find_applicant_by_email
      return if @attributes[:email].blank? || @attributes[:first_name].blank?

      Applicant.active.where(email: @attributes[:email]).find do |applicant|
        applicant.first_name.split.first.downcase == @attributes[:first_name].split.first.downcase
      end
    end

    def find_applicant_by_phone_number
      phone_number_formatted = PhoneNumberHelper.format_phone_number(@attributes[:phone_number])
      return if phone_number_formatted.blank? || @attributes[:first_name].blank?

      Applicant.active.where(phone_number: phone_number_formatted).find do |applicant|
        applicant.first_name.split.first.downcase == @attributes[:first_name].split.first.downcase
      end
    end

    def find_applicant_by_role_and_affiliation_number
      return if @attributes[:role].blank? || @attributes[:affiliation_number].blank?

      Applicant.active.joins(:organisations).where(
        affiliation_number: @attributes[:affiliation_number],
        role: @attributes[:role], organisations: { department_id: @department_id }
      ).first
    end
  end
end
