class Agent < ApplicationRecord
  validates_uniqueness_of :email
  belongs_to :department
end
