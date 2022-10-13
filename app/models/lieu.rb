class Lieu < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :name, :phone_number, :address
  ].freeze

  include Phonable

  validates :name, :address, presence: true
  validates :rdv_solidarites_lieu_id, presence: true, uniqueness: true

  belongs_to :organisation
  has_many :rdvs, dependent: :nullify

  def full_name
    "#{name} - #{address}"
  end
end
