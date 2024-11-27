class UnavailableCreneauLog < ApplicationRecord
  belongs_to :organisation

  scope :grouped_by_day, lambda {
    where(created_at: 30.days.ago.beginning_of_day..Date.today.end_of_day)
    .group("DATE(created_at)")
    .sum(:number_of_invitations_affected)
  }
end
