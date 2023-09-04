module Stats
  module MonthlyStats
    class UpsertStatsJob < ApplicationJob
      def perform
        # We upsert the monthly stats with last month stats to only record complete months
        Stats::MonthlyStats::UpsertStatJob.perform_async("Department", nil, 1.month.ago)

        Department.find_each do |department|
          Stats::MonthlyStats::UpsertStatJob.perform_async("Department", department.id, 1.month.ago)
        end

        Organisation.find_each do |organisation|
          Stats::MonthlyStats::UpsertStatJob.perform_async("Organisation", organisation.id, 1.month.ago)
        end
      end
    end
  end
end
