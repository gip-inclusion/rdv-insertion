class Motif < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :name, :deleted_at, :location_type, :name, :reservable_online, :rdv_solidarites_service_id, :category, :collectif
  ].freeze
  CATEGORIES_ENUM = {
    rsa_orientation: 0,
    rsa_accompagnement: 1,
    rsa_orientation_on_phone_platform: 2,
    rsa_cer_signature: 3,
    rsa_insertion_offer: 4,
    rsa_follow_up: 5
  }.freeze
  CATEGORIES_NAMES_MAPPING = {
    "rsa_orientation" => "RSA orientation",
    "rsa_accompagnement" => "RSA accompagnement",
    "rsa_orientation_on_phone_platform" => "RSA orientation sur plateforme téléphonique",
    "rsa_cer_signature" => "RSA signature CER",
    "rsa_insertion_offer" => "RSA offre insertion pro",
    "rsa_follow_up" => "RSA suivi"
  }.freeze

  enum location_type: { public_office: 0, phone: 1, home: 2 }
  enum category: CATEGORIES_ENUM

  belongs_to :organisation

  validates :rdv_solidarites_motif_id, uniqueness: true, presence: true
  validates :name, :location_type, presence: true
end
