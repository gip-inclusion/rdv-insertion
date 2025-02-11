module Users
  class Find < BaseService
    def initialize(attributes:, department_id:)
      @attributes = attributes.deep_symbolize_keys
      @department_id = department_id
    end

    def call
      result.user = find_matching_user
    end

    private

    def find_matching_user
      find_user_by_nir ||
        find_user_by_department_internal_id ||
        find_user_by_role_and_affiliation_number ||
        find_user_by_email ||
        find_user_by_phone_number
    end

    def find_user_by_nir
      return if formatted_nir_attribute.blank?

      User.active.find_by(nir: formatted_nir_attribute)
    end

    def find_user_by_department_internal_id
      return if @attributes[:department_internal_id].blank?

      User.active.joins(:organisations).where(
        department_internal_id: @attributes[:department_internal_id],
        organisations: { department_id: @department_id }
      ).first
    end

    def find_user_by_email
      return if @attributes[:email].blank? || @attributes[:first_name].blank?

      User.active.where(email: @attributes[:email]).find do |user|
        user.first_name.split.first.downcase == @attributes[:first_name].split.first.downcase
      end
    end

    def find_user_by_phone_number
      return if phone_number_formatted.blank? || @attributes[:first_name].blank?

      User.active.where(phone_number: phone_number_formatted).find do |user|
        user.first_name.split.first.downcase == @attributes[:first_name].split.first.downcase
      end
    end

    def find_user_by_role_and_affiliation_number
      return if @attributes[:role].blank? || @attributes[:affiliation_number].blank?

      User.active.joins(:organisations).where(
        affiliation_number: @attributes[:affiliation_number],
        role: @attributes[:role], organisations: { department_id: @department_id }
      ).first
    end

    def phone_number_formatted
      PhoneNumberHelper.format_phone_number(@attributes[:phone_number])
    end

    def formatted_nir_attribute
      NirHelper.format_nir(@attributes[:nir])
    end
  end
end
