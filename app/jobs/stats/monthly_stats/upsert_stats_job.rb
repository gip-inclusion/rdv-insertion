module Stats
  module MonthlyStats
    class UpsertStatsJob < ApplicationJob
      def perform
        department_numbers = Department.pluck(:number).push("all")
        department_numbers.each do |department_number|
          # We upsert the monthly stats with last month stats to only record complete months
          Stats::MonthlyStats::UpsertStatJob.perform_async(department_number, 1.month.ago)
        end
      end
    end
  end
end
