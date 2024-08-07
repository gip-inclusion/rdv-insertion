class AddressGeocoding < ApplicationRecord
  belongs_to :user

  def street_address
    [house_number, street].compact_blank.join(" ").presence
  end
end
