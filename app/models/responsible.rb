class Responsible < ApplicationRecord
  has_many :organisations, dependent: :nullify

  def full_name
    "#{first_name.downcase.capitalize} #{last_name.downcase.capitalize}"
  end
end
