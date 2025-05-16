class Delivery::ByLetter < ApplicationRecord
  self.table_name = "letter_deliveries"

  include ActsAsDeliveryMethod
end
