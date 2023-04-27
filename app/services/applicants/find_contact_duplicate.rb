# Finds an applicant that have the same email or the same phone number with a different first name
module Applicants
  class FindContactDuplicate < BaseService
    def initialize(email:, phone_number:, role:, first_name:)
      @email = email
      @phone_number = phone_number
      @role = role
      @first_name = first_name
    end

    def call
      # If it is a conjoint it shares the same phone number and tel number with the demandeur
      return if @role == "conjoint"
      return if @first_name.blank?

      result.contact_duplicate = contact_duplicate
    end

    private

    def contact_duplicate
      email_duplicate || phone_number_duplicate
    end

    def email_duplicate
      return if @email.blank?

      email_duplicate = Applicant.active.where(email: @email).reject(&:conjoint?)
                                 .find do |applicant|
        applicant.first_name.split.first.downcase != @first_name.split.first.downcase
      end
      return unless email_duplicate

      result.duplicate_attribute = :email
      email_duplicate
    end

    def phone_number_duplicate
      return if @phone_number.blank?

      phone_number_duplicate = Applicant.active.where(phone_number: phone_number_formatted).reject(&:conjoint?)
                                        .find do |applicant|
        applicant.first_name.split.first.downcase != @first_name.split.first.downcase
      end
      return unless phone_number_duplicate

      result.duplicate_attribute = :phone_number
      phone_number_duplicate
    end

    def phone_number_formatted
      PhoneNumberHelper.format_phone_number(@phone_number)
    end
  end
end
