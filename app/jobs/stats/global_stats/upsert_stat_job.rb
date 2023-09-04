class StatsJobError < StandardError; end

module Stats
  module GlobalStats
    class UpsertStatJob < ApplicationJob
      def perform(structure_type, structure_id)
        upsert_stat_record_for_global_stats =
          Stats::GlobalStats::UpsertStat.call(structure_type: structure_type, structure_id: structure_id)

        return if upsert_stat_record_for_global_stats.success?

        raise StatsJobError, upsert_stat_record_for_global_stats.errors.join(" - ")
      end
    end
  end
end
