class BlockedUser < ApplicationRecord
  belongs_to :user

  scope :grouped_by_month, lambda { |starts_at = Time.zone.parse("01/06/2021"), ends_at = Time.zone.now|
    where(created_at: starts_at..ends_at).group(Arel.sql("DATE_TRUNC('month', created_at)"))
                                         .order(Arel.sql("DATE_TRUNC('month', created_at)"))
                                         .count
  }

  def self.already_counted?(user_id:)
    where("created_at > ?", 30.days.ago.beginning_of_day).exists?(user_id:)
  end
end
