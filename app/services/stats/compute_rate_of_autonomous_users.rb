module Stats
  class ComputeRateOfAutonomousUsers < BaseService
    def initialize(users:)
      @users = users
    end

    def call
      result.value = compute_rate_of_autonomous_users
    end

    private

    # Rate of rdvs taken in autonomy
    def compute_rate_of_autonomous_users
      (autonomous_users.count / (
        @users.count.nonzero? || 1
      ).to_f) * 100
    end

    def autonomous_users
      @autonomous_users ||= @users.joins(:participations).where(participations: { created_by_type: "User" })
    end
  end
end
