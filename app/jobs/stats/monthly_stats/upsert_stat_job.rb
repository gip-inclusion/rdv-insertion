class StatsJobError < StandardError; end

module Stats
  module MonthlyStats
    class UpsertStatJob < ApplicationJob
      def perform(structure_type, structure_id, date_string)
        upsert_stat_record_for_monthly_stats =
          Stats::MonthlyStats::UpsertStat.call(
            structure_type: structure_type, structure_id: structure_id, date_string: date_string
          )

        return if upsert_stat_record_for_monthly_stats.success?

        raise StatsJobError, upsert_stat_record_for_monthly_stats.errors.join(" - ")
      end
    end
  end
end
