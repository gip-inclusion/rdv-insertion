class BlockedUser < ApplicationRecord
  belongs_to :user
  # default start time is 01/01/2025 since the data is not available before
  scope :grouped_by_month, lambda { |starts_at = Time.zone.parse("01/01/2025"), ends_at = Time.zone.now|
    where(created_at: starts_at..ends_at).group(Arel.sql("DATE_TRUNC('month', created_at)"))
                                         .order(Arel.sql("DATE_TRUNC('month', created_at)"))
                                         .count
  }

  def self.already_counted?(user_id:)
    where("created_at > ?", 30.days.ago.beginning_of_day).exists?(user_id:)
  end
end
