class Department < ApplicationRecord
  include HasLogo

  validates :name, :capital, :number, :pronoun, presence: true

  has_many :organisations, dependent: :nullify
  has_many :invitations, dependent: :nullify
  has_many :archives, dependent: :restrict_with_error

  has_many :applicants, through: :organisations
  has_many :configurations, through: :organisations
  has_many :motif_categories, -> { distinct }, through: :configurations
  has_many :file_configurations, through: :configurations
  has_many :agents, through: :organisations
  has_many :rdvs, through: :organisations
  has_many :participations, through: :rdvs
  has_many :rdv_contexts, through: :applicants
  has_many :archived_applicants, through: :archives, source: :applicant
  has_many :tags, through: :organisations

  scope :displayed_in_stats, -> { where(display_in_stats: true) }

  def name_with_region
    "#{name}, #{region}"
  end
end
