module Applicant::Address
  def street_address
    split_address.present? ? split_address[1].strip.gsub(/-$/, "").gsub(/,$/, "").gsub(/\.$/, "") : nil
  end

  def zipcode_and_city
    split_address.present? ? split_address[2].strip : nil
  end

  private

  def split_address
    address&.match(/^(.+) (\d{5}.*)$/m)
  end
end
