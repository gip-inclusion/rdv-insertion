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
            sorted_values = initial_value.merge({ date.strftime("%m/%Y") => result })
                                         .sort_by { |d, _v| Date.strptime(d, "%m/%Y") }
                                         .drop_while { |d, v| d.ends_with?("2022") && v.zero? }
                                         .to_h

            stat.update!(attribute_name => sorted_values)
          end
        end
      end
    end
  end
end
