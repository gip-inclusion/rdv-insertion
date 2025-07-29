module Stats
  module MonthlyStats
    class UpsertStatsJob < Stats::BaseJob
      def perform
        Stats::MonthlyStats::UpsertStatJob.perform_later("Department", nil)

        Department.find_each do |department|
          Stats::MonthlyStats::UpsertStatJob.perform_later("Department", department.id)
        end

        Organisation.find_each do |organisation|
          Stats::MonthlyStats::UpsertStatJob.perform_later("Organisation", organisation.id)
        end
      end
    end
  end
end
