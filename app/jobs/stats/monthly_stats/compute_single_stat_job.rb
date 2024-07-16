module Stats
  module MonthlyStats
    class ComputeSingleStatJob < ApplicationJob
      sidekiq_options retry: 3

      def perform(stat_id, stat_name, date)
        Timeout.timeout(20.minutes) do
          date = date.to_datetime
          stat = Stat.find(stat_id)
          result = Stats::MonthlyStats::ComputeForFocusedMonth.new(stat:, date:).send(stat_name)

          Stat.transaction do
            stat.reload(lock: true)
            stat.update!(
              stat_name => stat.send(stat_name).merge({ date.strftime("%m/%Y") => result })
            )
          end
        end
      end
    end
  end
end
