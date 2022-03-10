class Responsible < ApplicationRecord
  has_many :organisations, dependent: :nullify
  validates :first_name, :last_name, :role, presence: true

  def full_name
    "#{first_name.downcase.capitalize} #{last_name.downcase.capitalize}"
  end
end
