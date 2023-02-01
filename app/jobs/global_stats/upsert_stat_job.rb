class StatsJobError < StandardError; end

module GlobalStats
  class UpsertStatJob < ApplicationJob
    def perform(department_number)
      upsert_stat_record_for_global_stats = Stats::GlobalStats::UpsertStat.call(department_number: department_number)

      return if upsert_stat_record_for_global_stats.success?

      raise StatsJobError, upsert_stat_record_for_global_stats.errors.join(" - ")
    end
  end
end
