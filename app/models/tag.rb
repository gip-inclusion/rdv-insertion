class Tag < ApplicationRecord
  has_many :tag_applicants, dependent: :destroy
  has_many :tag_organisations, dependent: :destroy

  has_many :applicants, through: :tag_applicants
  has_many :organisations, through: :tag_organisations

  validates :value, presence: true

  def to_s
    value
  end
end
