class Department < ApplicationRecord
  validates :name, :capital, :number, presence: true

  has_many :organisations, dependent: :nullify

  def name_with_region
    "#{name}, #{region}"
  end
end
