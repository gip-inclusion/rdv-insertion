class TagUser < ApplicationRecord
  belongs_to :tag
  belongs_to :user

  validates :tag_id, uniqueness: { scope: :user_id }
end
