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

    def users
      @users ||= User.where(department_id: @department_id).active
    end

    def find_matching_user
      find_user_by_nir ||
        find_user_by_department_internal_id ||
        find_user_by_email ||
        find_user_by_phone_number ||
        find_user_by_role_and_affiliation_number
    end

    def find_user_by_nir
      return if formatted_nir_attribute.blank?

      users.find_by(nir: formatted_nir_attribute)
    end

    def find_user_by_department_internal_id
      return if @attributes[:department_internal_id].blank?

      users.find_by(department_internal_id: @attributes[:department_internal_id])
    end

    def find_user_by_email
      return if @attributes[:email].blank? || @attributes[:first_name].blank?

      users.where(email: @attributes[:email]).find do |user|
        user.first_name.split.first.downcase == @attributes[:first_name].split.first.downcase
      end
    end

    def find_user_by_phone_number
      return if phone_number_formatted.blank? || @attributes[:first_name].blank?

      users.where(phone_number: phone_number_formatted).find do |user|
        user.first_name.split.first.downcase == @attributes[:first_name].split.first.downcase
      end
    end

    def find_user_by_role_and_affiliation_number
      return if @attributes[:role].blank? || @attributes[:affiliation_number].blank?

      users.find_by(affiliation_number: @attributes[:affiliation_number], role: @attributes[:role])
    end

    def phone_number_formatted
      PhoneNumberHelper.format_phone_number(@attributes[:phone_number])
    end

    def formatted_nir_attribute
      NirHelper.format_nir(@attributes[:nir])
    end
  end
end
