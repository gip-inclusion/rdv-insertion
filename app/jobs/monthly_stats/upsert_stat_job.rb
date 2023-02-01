class StatsJobError < StandardError; end

module MonthlyStats
  class UpsertStatJob < ApplicationJob
    def perform(department_number, date_string)
      upsert_stat_record_for_monthly_stats = Stats::MonthlyStats::UpsertStat.call(
        department_number: department_number, date_string: date_string
      )

      return if upsert_stat_record_for_monthly_stats.success?

      raise StatsJobError, upsert_stat_record_for_monthly_stats.errors.join(" - ")
    end
  end
end
