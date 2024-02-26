class StatsJobError < StandardError; end

module Stats
  module GlobalStats
    class UpsertStatJob < ApplicationJob
      sidekiq_options retry: 1

      def perform(structure_type, structure_id)
        # to do : add timeout as a global concern for all jobs and remove it here
        Timeout.timeout(60.minutes) do
          upsert_stat_record_for_global_stats =
            Stats::GlobalStats::UpsertStat.call(structure_type: structure_type, structure_id: structure_id)

          return if upsert_stat_record_for_global_stats.success?

          raise StatsJobError, upsert_stat_record_for_global_stats.errors.join(" - ")
        end
      end
    end
  end
end
