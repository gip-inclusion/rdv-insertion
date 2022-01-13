class Department < ApplicationRecord
  validates :name, :capital, :number, :pronoun, presence: true

  has_many :organisations, dependent: :nullify
  has_many :applicants, dependent: :nullify
  has_many :agents, through: :organisations
  has_many :invitations, through: :organisations
  has_many :rdvs, through: :organisations

  def name_with_region
    "#{name}, #{region}"
  end

  # For now we consider that if there is a config at the department level
  # then it is the same as the ones at orga level
  def configuration
    organisations.includes(:configuration).map(&:configuration).find(&:present?)
  end
end
