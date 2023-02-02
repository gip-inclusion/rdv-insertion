module Stats
  module GlobalStats
    class UpsertStat < BaseService
      def initialize(department_number:)
        @department_number = department_number
      end

      def call
        assign_global_stats_attributes_to_stat_record
        save_record!(stat)
      end

      private

      def stat
        @stat ||= Stat.find_or_initialize_by(department_number: @department_number)
      end

      def assign_global_stats_attributes_to_stat_record
        ActiveRecord::Base.uncached { stat.assign_attributes(compute_global_stats.stat_attributes) }
      end

      def compute_global_stats
        @compute_global_stats ||= Stats::GlobalStats::Compute.call(stat: stat)
      end
    end
  end
end
