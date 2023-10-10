module Stats
  class ComputeRateOfUsersWithRdvSeen < BaseService
    def initialize(rdv_contexts:)
      @rdv_contexts = rdv_contexts
    end

    def call
      result.value = compute_rate_of_users_with_rdv_seen
    end

    private

    def compute_rate_of_users_with_rdv_seen
      (users_with_rdv_seen.count / (
        users.count.nonzero? || 1
      ).to_f) * 100
    end

    def users
      @users ||= User.joins(:rdv_contexts).where(rdv_contexts: @rdv_contexts).distinct
    end

    def users_with_rdv_seen
      @users_with_rdv_seen ||= User.where(participations: participations_with_rdv_seen).distinct
    end

    def participations_with_rdv_seen
      @participations_with_rdv_seen ||= Participation.where(rdv_context: @rdv_contexts).seen
    end
  end
end
