class PostRdvOrientation < ApplicationRecord
  belongs_to :participation
  belongs_to :orientation_type

  has_one :organisation, through: :participation

  validates :participation_id, uniqueness: true

  def organisation_id = organisation.id
end
