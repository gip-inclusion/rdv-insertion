module Stats
  module MonthlyStats
    class UpsertStatJob < ApplicationJob
      def perform(structure_type, structure_id, until_date_string)
        @stat = Stat.find_or_initialize_by(statable_type: structure_type, statable_id: structure_id)
        @date = @stat.statable&.created_at || DateTime.parse("01/01/2022")

        reset_stat_values!

        while @date < until_date_string.to_date
          compute_monthly_stats

          @date += 1.month
        end
      end

      private

      def reset_stat_values!
        Stat::MONTHLY_STAT_ATTRIBUTES.each do |attribute_name|
          @stat[attribute_name] = {}
        end

        @stat.save!
      end

      def compute_monthly_stats
        Stat::MONTHLY_STAT_ATTRIBUTES.each do |method_name|
          Stats::MonthlyStats::ComputeSingleStatJob.perform_async(@stat.id, method_name, @date)
        end
      end
    end
  end
end
