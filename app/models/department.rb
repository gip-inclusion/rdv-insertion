class Department < ApplicationRecord
  validates :name, :capital, :number, presence: true

  has_many :organisations, dependent: :nullify
  has_many :applicants, through: :organisations
  has_many :agents, through: :organisations
  has_many :invitations, through: :organisations
  has_many :rdvs, through: :organisations

  def name_with_region
    "#{name}, #{region}"
  end

  def name_with_pronoun
    separator = pronoun == "de l'" ? "" : " "
    "#{pronoun}#{separator}#{name}"
  end
end
