class Tag < ApplicationRecord
  has_many :tag_users, dependent: :destroy
  has_many :tag_organisations, dependent: :destroy

  has_many :users, through: :tag_users
  has_many :organisations, through: :tag_organisations

  validates :value, presence: true

  sanitize :value

  def to_s
    value
  end
end
