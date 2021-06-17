class Agent < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  belongs_to :department
end
