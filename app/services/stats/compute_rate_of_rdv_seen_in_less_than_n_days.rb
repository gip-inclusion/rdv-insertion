module Stats
  class ComputeRateOfRdvSeenInLessThanNDays < BaseService
    def initialize(rdv_contexts:, number_of_days:)
      @rdv_contexts = rdv_contexts
      @number_of_days = number_of_days
    end

    def call
      result.value = compute_rate_of_rdv_contexts_with_rdv_seen_in_less_than_n_days
    end

    private

    # Rate of rdv_contexts with rdv seen in less than n days
    def compute_rate_of_rdv_contexts_with_rdv_seen_in_less_than_n_days
      (rdv_contexts_with_rdv_seen_in_less_than_n_days.count / (
        rdv_contexts_created_more_than_n_days_ago.count.nonzero? || 1
      ).to_f) * 100
    end

    def rdv_contexts_with_rdv_seen_in_less_than_n_days
      @rdv_contexts_with_rdv_seen_in_less_than_n_days ||= begin
        rdv_contexts = []

        rdv_contexts_with_rdvs_seen_created_more_than_n_days_ago.find_in_batches(batch_size: 100) do |batch|
          rdv_contexts += batch.select { |record| record.rdv_seen_delay_in_days < @number_of_days }
        end

        rdv_contexts
      end
    end

    def rdv_contexts_with_rdvs_seen_created_more_than_n_days_ago
      @rdv_contexts_with_rdvs_seen_created_more_than_n_days_ago ||=
        rdv_contexts_created_more_than_n_days_ago.joins(:participations).where(participations: { status: "seen" })
                                                 .distinct
    end

    def rdv_contexts_created_more_than_n_days_ago
      @rdv_contexts_created_more_than_n_days_ago ||= @rdv_contexts.where("rdv_contexts.created_at < ?",
                                                                         @number_of_days.days.ago)
    end
  end
end
