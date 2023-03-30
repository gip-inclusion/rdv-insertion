class Organisation < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [:name, :phone_number, :email].freeze

  include PgSearch::Model
  include HasLogo
  include Phonable

  validates :rdv_solidarites_organisation_id, uniqueness: true, allow_nil: true
  validates :name, presence: true
  validates :email, allow_blank: true, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }

  belongs_to :department
  belongs_to :messages_configuration, optional: true
  has_many :rdvs, dependent: :nullify
  has_many :lieux, dependent: :nullify
  has_many :motifs, dependent: :nullify
  has_many :configurations_organisations, dependent: :delete_all
  has_many :agent_roles, dependent: :destroy
  has_and_belongs_to_many :applicants, dependent: :nullify
  has_and_belongs_to_many :invitations, dependent: :nullify
  has_and_belongs_to_many :webhook_endpoints

  has_many :agents, through: :agent_roles
  has_many :configurations, through: :configurations_organisations
  has_many :motif_categories, through: :configurations

  delegate :name, :name_with_region, :number, to: :department, prefix: true

  pg_search_scope(
    :search_by_text,
    using: { tsearch: { prefix: true } },
    against: [:name, :slug]
  )

  def rdv_solidarites_url
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{rdv_solidarites_organisation_id}"
  end

  def to_s
    name
  end

  def as_json(_opts = {})
    super.merge(department_number: department_number, motif_categories: motif_categories)
  end

  def phone_number_is_valid?
    # Override phone_number_is_valid? method from Phonable for 4 digits organisations
    return true if phone_number.match(/^\d{4}$/)

    super
  end
end
