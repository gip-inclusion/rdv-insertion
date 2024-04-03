module User::Address
  extend ActiveSupport::Concern

  included do
    squishes :address
  end

  def street_address
    split_address.present? ? split_address[1].strip.gsub(/-$/, "").gsub(/,$/, "").gsub(/\.$/, "") : nil
  end

  def zipcode_and_city
    split_address.present? ? split_address[2].strip : nil
  end

  def zipcode
    address&.match(/\d{5}/)&.to_s
  end

  private

  def split_address
    address&.match(/^(.+) (\d{5}.*)$/m)
  end
end
