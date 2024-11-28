class UnavailableCreneauLog < ApplicationRecord
  belongs_to :organisation

  scope :grouped_by_day, lambda { |starts_at, ends_at|
    where(created_at: starts_at..ends_at)
      .group("DATE(created_at)")
      .sum(:number_of_invitations_affected)
  }
end
