class Department < ApplicationRecord
  include HasLogo

  validates :name, :capital, :number, :pronoun, presence: true

  has_many :organisations, dependent: :nullify
  has_many :applicants, dependent: :nullify
  has_many :invitations, dependent: :nullify
  has_many :configurations, through: :organisations
  has_many :motif_categories, through: :configurations

  has_many :agents, through: :organisations
  has_many :rdvs, through: :organisations
  has_many :rdv_contexts, through: :applicants

  scope :displayed_in_stats, -> { where(display_in_stats: true) }

  def name_with_region
    "#{name}, #{region}"
  end
end
