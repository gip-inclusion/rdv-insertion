module RdvSolidarites
  class User < Base
    RECORD_ATTRIBUTES = [
      :id, :first_name, :last_name, :birth_date, :email, :phone_number,
      :birth_name, :address, :affiliation_number, :notification_email
    ].freeze
    attr_reader(*RECORD_ATTRIBUTES)

    def deleted?
      email&.ends_with?("@deleted.rdv-solidarites.fr")
    end

    def email
      # Override email to return either email or notification_email
      @attributes[:notification_email].presence || @attributes[:email].presence
    end

    def attributes
      attrs = super
      attrs[:email] = attrs.delete(:notification_email) if attrs[:notification_email].present?
      attrs
    end

    def organisation_ids
      @attributes[:user_profiles].map do |user_profile_attributes|
        user_profile_attributes.dig(:organisation, :id)
      end.compact
    end

    def user_profiles
      @attributes[:user_profiles].to_a
    end
  end
end
