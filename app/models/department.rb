class Department < ApplicationRecord
  validates :name, :capital, :number, presence: true

  has_many :organisations, dependent: :nullify

  def name_with_region
    "#{name}, #{region}"
  end

  # For now we consider that if there is a config at the department level
  # then it is the same as the ones at orga level
  def configuration
    organisations.includes(:configuration).map(&:configuration).find(&:present?)
  end
end
