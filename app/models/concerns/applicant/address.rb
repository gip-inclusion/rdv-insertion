module Applicant::Address
  extend ActiveSupport::Concern

  included do
    before_save :format_address
  end

  def street_address
    split_address.present? ? split_address[1].strip.gsub(/-$/, "").gsub(/,$/, "").gsub(/\.$/, "") : nil
  end

  def zipcode_and_city
    split_address.present? ? split_address[2].strip : nil
  end

  private

  def format_address
    return if address.blank?

    self.address = address.squish
  end

  def split_address
    address&.match(/^(.+) (\d{5}.*)$/m)
  end
end
