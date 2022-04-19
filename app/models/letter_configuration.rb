class LetterConfiguration < ApplicationRecord
  has_many :organisations, dependent: :nullify
  validates :direction_names, presence: true
end
