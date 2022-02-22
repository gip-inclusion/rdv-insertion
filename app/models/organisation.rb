class Organisation < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [:name, :phone_number, :email].freeze
  TIME_TO_ACCEPT_INVITATION = 3.days

  validates :rdv_solidarites_organisation_id, uniqueness: true, allow_nil: true
  validates :name, presence: true
  validates :phone_number, length: { is: 10 },
                           format: { with: /\d+/, message: "Le numéro ne doit contenir que 10 chiffres" },
                           allow_nil: true

  belongs_to :department
  has_and_belongs_to_many :agents, dependent: :nullify
  has_and_belongs_to_many :applicants, dependent: :nullify
  has_and_belongs_to_many :invitations, dependent: :nullify
  belongs_to :configuration
  has_many :rdvs, dependent: :nullify

  delegate :notify_applicant?, to: :configuration
  delegate :name, :name_with_region, :number, to: :department, prefix: true

  def as_json(_opts = {})
    super.merge(department_number: department_number)
  end
end
