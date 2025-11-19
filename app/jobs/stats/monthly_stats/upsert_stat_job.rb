module Stats
  module MonthlyStats
    class UpsertStatJob < Stats::BaseJob
      def perform(
        structure_type,
        structure_id,
        from_date_string = 1.year.ago.to_s,
        until_date_string = Time.zone.now.end_of_month.to_s
      )
        @stat = Stat.find_or_initialize_by(statable_type: structure_type, statable_id: structure_id)
        date = from_date_string.to_date

        while date < until_date_string.to_date
          compute_monthly_stats(date)

          date += 1.month
        end
      end

      private

      def compute_monthly_stats(date)
        Stat::MONTHLY_STAT_ATTRIBUTES.each do |method_name|
          Stats::MonthlyStats::ComputeAndSaveSingleStatJob.perform_later(@stat.id, method_name, date)
        end
      end
    end
  end
end
