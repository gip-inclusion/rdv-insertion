class Department < ApplicationRecord
  validates :name, :capital, :number, :pronoun, presence: true

  has_many :organisations, dependent: :nullify
  has_many :applicants, dependent: :nullify
  has_many :invitations, dependent: :nullify

  has_many :agents, through: :organisations
  has_many :rdvs, through: :organisations
  has_many :rdv_contexts, through: :applicants

  def name_with_region
    "#{name}, #{region}"
  end

  def configurations
    organisations.includes(:configurations).flat_map(&:configurations)
  end
end
