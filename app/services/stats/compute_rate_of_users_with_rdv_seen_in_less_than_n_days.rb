module Stats
  class ComputeRateOfUsersWithRdvSeenInLessThanNDays < BaseService
    def initialize(users:, number_of_days:)
      @users = users
      @number_of_days = number_of_days
    end

    def call
      result.value = compute_rate_of_users_with_rdv_seen_in_less_than_n_days
    end

    private

    # Rate of users with rdv seen in less than n days
    def compute_rate_of_users_with_rdv_seen_in_less_than_n_days
      (users_with_rdv_seen_in_less_than_n_days.count / (
        users_created_more_than_n_days_ago.count.nonzero? || 1
      ).to_f) * 100
    end

    def users_with_rdv_seen_in_less_than_n_days
      @users_with_rdv_seen_in_less_than_n_days ||= begin
        users = []

        users_with_rdvs_seen_created_more_than_n_days_ago.find_in_batches(batch_size: 100) do |batch|
          users += batch.select { |user| user.rdv_seen_delay_in_days < @number_of_days }
        end

        users
      end
    end

    def users_with_rdvs_seen_created_more_than_n_days_ago
      @users_with_rdvs_seen_created_more_than_n_days_ago ||=
        users_created_more_than_n_days_ago.joins(:participations).where(participations: { status: "seen" }).distinct
    end

    def users_created_more_than_n_days_ago
      @users_created_more_than_n_days_ago ||= @users.where("users.created_at < ?", @number_of_days.days.ago)
    end
  end
end
