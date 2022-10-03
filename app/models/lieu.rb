class Lieu < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :name, :phone_number, :address
  ].freeze

  validates :name, :address, presence: true
  validates :rdv_solidarites_lieu_id, presence: true, uniqueness: true

  belongs_to :organisation
  has_many :rdvs, dependent: :restrict_with_error


  def full_name
    "#{name} - #{address}"
  end
end
