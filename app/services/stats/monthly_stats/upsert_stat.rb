module Stats
  module MonthlyStats
    class UpsertStat < BaseService
      def initialize(department_number:, date_string:)
        @department_number = department_number
        @date_string = date_string
      end

      def call
        merge_monthly_stats_attributes_for_focused_month_to_stat_record
        save_record!(stat)
      end

      private

      def stat
        @stat ||= Stat.find_or_initialize_by(department_number: @department_number)
      end

      def merge_monthly_stats_attributes_for_focused_month_to_stat_record
        compute_monthly_stats_for_focused_month.stats_values.each do |stat_name, stat_value|
          stat_attribute = stat[stat_name] || {}
          if stat_name == :rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month
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
