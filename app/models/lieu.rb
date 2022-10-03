class Lieu < ApplicationRecord
  SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES = [
    :name, :phone_number, :address
  ].freeze

  validates :name, :address, presence: true

  belongs_to :organisation
  has_many :lieux, dependent: :restrict_with_error
end
