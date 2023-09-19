module Stats
  module MonthlyStats
    class UpsertStat < BaseService
      def initialize(structure_type:, structure_id:, date_string:)
        @structure_type = structure_type
        @structure_id = structure_id
        @date_string = date_string
      end

      def call
        merge_monthly_stats_attributes_for_focused_month_to_stat_record
        save_record!(stat)
      end

      private

      def stat
        @stat ||= Stat.find_or_initialize_by(statable_type: @structure_type, statable_id: @structure_id)
      end

      def merge_monthly_stats_attributes_for_focused_month_to_stat_record
        compute_monthly_stats_for_focused_month.stats_values.each do |stat_name, stat_value|
          stat_attribute = stat[stat_name] || {}
          if stat_name == :rate_of_applicants_oriented_in_less_than_30_days_by_month
            # cette stat est calculée avec 1 mois de décalage par rapport aux autres
            stat_attribute.merge!({ (date - 1.month).strftime("%m/%Y") => stat_value })
          else
            stat_attribute.merge!({ date.strftime("%m/%Y") => stat_value })
          end
          stat[stat_name] = stat_attribute
        end
      end

      def compute_monthly_stats_for_focused_month
        @compute_monthly_stats_for_focused_month ||= Stats::MonthlyStats::ComputeForFocusedMonth.call(
          stat: stat,
          date: date
        )
      end

      def date
        @date ||= @date_string.to_date
      end
    end
  end
end
