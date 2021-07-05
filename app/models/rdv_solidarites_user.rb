class RdvSolidaritesUser
  USER_ATTRIBUTES = [
    :id, :first_name, :last_name, :birth_date, :email, :phone_number,
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

  def as_json(_opts = {})
    # we want to send formatted dates
    @attributes.merge(
      {
        created_at: @attributes[:created_at]&.to_date&.strftime("%m/%d/%Y"),
        invited_at: @attributes[:invited_at]&.to_date&.strftime("%m/%d/%Y")
      }
    )
  end
end
