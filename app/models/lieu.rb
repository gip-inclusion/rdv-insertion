class Lieu < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :name, :phone_number, :address
  ].freeze

  validates :name, :address, presence: true
  validates :rdv_solidarites_lieu_id, presence: true, uniqueness: true
  validates :phone_number, phone_number: true

  belongs_to :organisation
  has_many :rdvs, dependent: :nullify

  def full_name
    "#{name} - #{address}"
  end
end
