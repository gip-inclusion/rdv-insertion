class Department < ApplicationRecord
  validates :rdv_solidarites_organisation_id, uniqueness: true, allow_nil: true
  validates :name, :capital, :number, presence: true
  has_and_belongs_to_many :agents, dependent: :nullify
  has_many :applicants, dependent: :nullify
  has_one :configuration, dependent: :nullify
  has_many :rdvs, dependent: :nullify

  delegate :notify_applicant?, to: :configuration
  delegate :no_invitation?, to: :configuration

  def name_with_region
    "#{name}, #{region}"
  end
end
