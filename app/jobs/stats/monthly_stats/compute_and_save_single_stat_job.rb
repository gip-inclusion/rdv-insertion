module Stats
  module MonthlyStats
    class ComputeAndSaveSingleStatJob < ApplicationJob
      sidekiq_options queue: :stats, retry: 3

      def perform(stat_id, attribute_name, date)
        Timeout.timeout(20.minutes) do
          date = date.to_datetime
          stat = Stat.find(stat_id)
          result = Stats::MonthlyStats::ComputeForFocusedMonth.new(stat:, date:).send(attribute_name)

          Stat.transaction do
            stat.reload(lock: true)
            initial_value = stat.send(attribute_name) || {}
            stat.update!(attribute_name => new_values_with_result(initial_value, result))
          end
        end
      end

      private

      def new_values_with_result(initial_value, result)
        initial_value.merge({ date.strftime("%m/%Y") => result })
                     .sort_by { |d, _v| Date.strptime(d, "%m/%Y") }
                     .drop_while { |d, v| d.ends_with?("2022") && v.zero? }
                     .to_h
      end
    end
  end
end
