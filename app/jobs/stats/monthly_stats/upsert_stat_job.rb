class StatsJobError < StandardError; end

module Stats
  module MonthlyStats
    class UpsertStatJob < ApplicationJob
      sidekiq_options retry: 1

      def perform(structure_type, structure_id, until_date_string)
        # to do : add timeout as a global concern for all jobs and remove it here
        Timeout.timeout(30.minutes) do
          upsert_stat_record_for_monthly_stats =
            Stats::MonthlyStats::UpsertStat.call(
              structure_type: structure_type, structure_id: structure_id, until_date_string: until_date_string
            )

          return if upsert_stat_record_for_monthly_stats.success?

          raise StatsJobError, upsert_stat_record_for_monthly_stats.errors.join(" - ")
        end
      end
    end
  end
end
