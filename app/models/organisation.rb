class Organisation < ApplicationRecord
  include PgSearch::Model
  include HasLogo

  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [:name, :phone_number, :email].freeze

  validates :rdv_solidarites_organisation_id, uniqueness: true, allow_nil: true
  validates :name, presence: true

  belongs_to :department
  belongs_to :messages_configuration, optional: true
  has_many :rdvs, dependent: :nullify
  has_many :lieux, dependent: :nullify
  has_many :motifs, dependent: :nullify
  has_many :configurations_organisations, dependent: :delete_all
  has_many :configurations, through: :configurations_organisations
  has_many :motif_categories, through: :configurations
  has_and_belongs_to_many :agents, dependent: :nullify
  has_and_belongs_to_many :applicants, dependent: :nullify
  has_and_belongs_to_many :invitations, dependent: :nullify
  has_and_belongs_to_many :webhook_endpoints

  delegate :name, :name_with_region, :number, to: :department, prefix: true

  pg_search_scope(
    :search_by_text,
    using: { tsearch: { prefix: true } },
    against: [:name, :slug]
  )

  def rdv_solidarites_url
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{rdv_solidarites_organisation_id}"
  end

  def as_json(_opts = {})
    super.merge(department_number: department_number, motif_categories: motif_categories)
  end
end
