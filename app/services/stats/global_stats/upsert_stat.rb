module Stats
  module GlobalStats
    class UpsertStat < BaseService
      def initialize(structure_type:, structure_id:)
        @structure_type = structure_type
        @structure_id = structure_id
      end

      def call
        assign_global_stats_attributes_to_stat_record
        save_record!(stat)
      end

      private

      def stat
        @stat ||= Stat.find_or_initialize_by(statable_type: @structure_type, statable_id: @structure_id)
      end

      def assign_global_stats_attributes_to_stat_record
        stat.assign_attributes(compute_global_stats.stat_attributes)
      end

      def compute_global_stats
        @compute_global_stats ||= Stats::GlobalStats::Compute.call(stat: stat)
      end
    end
  end
end
