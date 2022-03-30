class LetterConfiguration < ApplicationRecord
  has_many :organisations, dependent: :nullify
  validates :direction_names, :motif, presence: true
end
