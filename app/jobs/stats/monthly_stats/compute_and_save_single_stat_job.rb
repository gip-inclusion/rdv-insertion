module Stats
  module MonthlyStats
    class ComputeAndSaveSingleStatJob < Stats::BaseJob
      sidekiq_options retry: 3

      def perform(stat_id, attribute_name, date)
        Timeout.timeout(20.minutes) do
          date = date.to_datetime
          stat = Stat.find(stat_id)
          result = Stats::MonthlyStats::ComputeForFocusedMonth.new(stat:, date:).send(attribute_name)
          stat.insert_month_result!(attribute_name, date, result)
        end
      end
    end
  end
end
