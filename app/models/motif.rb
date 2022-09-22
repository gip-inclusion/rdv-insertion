class Motif < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :name, :deleted_at, :location_type, :name, :reservable_online, :rdv_solidarites_service_id, :category, :collectif
  ].freeze

  enum location_type: { public_office: 0, phone: 1, home: 2 }
  enum category: { rsa_orientation: 0,
                   rsa_accompagnement: 1,
                   rsa_orientation_on_phone_platform: 2,
                   rsa_cer_signature: 3,
                   rsa_insertion_offer: 4 }

  belongs_to :organisation

  validates :rdv_solidarites_motif_id, uniqueness: true, presence: true
  validates :name, :category, :location_type, presence: true
end
