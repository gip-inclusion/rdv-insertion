module Stats
  class ComputeRateOfUsersWithRdvSeenInLessThanThirtyDays < BaseService
    def initialize(users:)
      @users = users
    end

    def call
      result.value = compute_rate_of_users_oriented_in_less_than_30_days
    end

    private

    # Rate of users with rdv seen in less than 30 days
    def compute_rate_of_users_oriented_in_less_than_30_days
      (users_oriented_in_less_than_30_days.count / (
        users_created_more_than_30_days_ago.count.nonzero? || 1
      ).to_f) * 100
    end

    def users_oriented_in_less_than_30_days
      @users_oriented_in_less_than_30_days ||=
        users_created_more_than_30_days_ago.select do |user|
          user_rdv_seen_delay_in_days = user.rdv_seen_delay_in_days
          user_rdv_seen_delay_in_days.present? && user_rdv_seen_delay_in_days < 30
        end
    end

    def users_created_more_than_30_days_ago
      @users_created_more_than_30_days_ago ||= @users.where("users.created_at < ?", 30.days.ago)
    end
  end
end
