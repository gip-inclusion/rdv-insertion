class Organisation < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [:name, :phone_number, :email].freeze

  validates :rdv_solidarites_organisation_id, uniqueness: true, allow_nil: true
  validates :name, presence: true

  belongs_to :department
  has_and_belongs_to_many :agents, dependent: :nullify
  has_and_belongs_to_many :applicants, dependent: :nullify
  has_and_belongs_to_many :invitations, dependent: :nullify
  has_and_belongs_to_many :configurations
  has_and_belongs_to_many :webhook_endpoints

  belongs_to :responsible, optional: true
  belongs_to :invitation_parameters, optional: true
  has_many :rdvs, dependent: :nullify

  delegate :name, :name_with_region, :number, to: :department, prefix: true

  def contexts
    configurations.map(&:context)
  end

  def as_json(_opts = {})
    super.merge(department_number: department_number)
  end
end
