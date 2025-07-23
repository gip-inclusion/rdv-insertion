class Organisation < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [:name, :phone_number, :email].freeze
  SEARCH_ATTRIBUTES = [:name, :slug].freeze

  include HasLogo
  include Searchable
  include Organisation::Archivable

  before_create { build_messages_configuration }

  validates :rdv_solidarites_organisation_id, uniqueness: true, allow_nil: true
  validates :name, :organisation_type, presence: true
  validates :email, allow_blank: true, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }
  validates :phone_number, phone_number: { allow_4_digits_numbers: true }
  validates :data_retention_duration_in_months, presence: true
  validate :data_retention_duration_in_months_bounds

  belongs_to :department
  has_one :stat, as: :statable, dependent: :destroy
  has_one :messages_configuration, dependent: :destroy
  has_one :dpa_agreement, dependent: :destroy

  has_many :category_configurations, dependent: :destroy
  has_many :rdvs, dependent: :restrict_with_exception
  has_many :participations, through: :rdvs
  has_many :lieux, dependent: :restrict_with_exception
  has_many :motifs, dependent: :restrict_with_exception
  has_many :agent_roles, dependent: :destroy
  has_many :users_organisations, dependent: :destroy
  has_many :tag_organisations, dependent: :destroy
  has_many :orientations, dependent: :restrict_with_error
  has_many :csv_exports, as: :structure, dependent: :destroy
  has_many :webhook_endpoints, dependent: :destroy

  has_many :users, through: :users_organisations
  has_many :agents, through: :agent_roles
  has_many :motif_categories, -> { distinct }, through: :category_configurations
  has_many :tags, through: :tag_organisations
  has_many :file_configurations, through: :category_configurations

  has_and_belongs_to_many :invitations, dependent: :nullify

  delegate :name, :name_with_region, :number, to: :department, prefix: true

  enum :organisation_type, {
    conseil_departemental: "conseil_departemental",
    delegataire_rsa: "delegataire_rsa",
    france_travail: "france_travail",
    siae: "siae",
    autre: "autre"
  }

  scope :displayed_in_stats, -> { where(display_in_stats: true) }

  ORGANISATION_TYPES_WITH_PARCOURS_ACCESS = %w[delegataire_rsa conseil_departemental france_travail].freeze

  def rdv_solidarites_url
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{rdv_solidarites_organisation_id}"
  end

  def rdv_solidarites_configuration_url
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{rdv_solidarites_organisation_id}/configuration"
  end

  def to_s
    name
  end

  def with_parcours_access?
    rsa_related? && department.with_parcours_access?
  end

  def rsa_related?
    organisation_type.in?(ORGANISATION_TYPES_WITH_PARCOURS_ACCESS)
  end

  def category_configurations_sorted
    category_configurations.order(:position)
  end

  def requires_dpa_acceptance?
    dpa_agreement.nil?
  end

  def inactive_users
    Organisation::UsersRetriever.new(organisation: self).inactive_users
  end

  private

  def data_retention_duration_in_months_bounds
    if data_retention_duration_in_months < 1
      errors.add(:data_retention_duration_in_months, "doit être au minimum de 1 mois")
    elsif data_retention_duration_in_months > 36
      errors.add(:data_retention_duration_in_months, "doit être au maximum de 3 ans")
    end
  end
end
