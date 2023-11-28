class MotifCategory < ApplicationRecord
  has_many :configurations, dependent: :restrict_with_exception
  has_many :rdv_contexts, dependent: :restrict_with_exception
  has_many :motifs, dependent: :restrict_with_exception
  belongs_to :template

  validates :short_name, presence: true, uniqueness: true
  validates :name, presence: true
  validates :rdv_solidarites_motif_category_id, uniqueness: true, allow_nil: true

  delegate :model, to: :template, prefix: true
  delegate :atelier?, to: :template

  scope :participation_optional, lambda { |participation_optional = true|
    where(participation_optional: participation_optional)
  }
end
