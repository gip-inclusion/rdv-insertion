class RdvSolidaritesUser
  USER_ATTRIBUTES = [
    :id, :first_name, :last_name, :birth_date, :email, :phone_number, :phone_number_formatted,
    :birth_name, :address, :affiliation_number, :created_at, :invited_at
  ].freeze

  attr_reader(*USER_ATTRIBUTES)

  def initialize(attributes = {})
    @attributes = attributes.deep_symbolize_keys
    USER_ATTRIBUTES.each do |attr_name|
      next unless @attributes.include?(attr_name)

      instance_variable_set("@#{attr_name}", @attributes[attr_name])
    end
  end

  def attributes
    @attributes.to_hash
  end
end
