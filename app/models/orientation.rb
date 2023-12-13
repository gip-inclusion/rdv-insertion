class Orientation < ApplicationRecord
  belongs_to :user
  belongs_to :organisation
  belongs_to :agent

  validates :starts_at, presence: true

  enum type: { social: 0, pro: 1, socio_pro: 2 }
end
