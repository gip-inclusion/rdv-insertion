module Stats
  module MonthlyStats
    class UpsertStatsJob < Stats::BaseJob
      def perform
        Stats::MonthlyStats::UpsertStatJob.perform_later("Department", nil, Time.zone.now)

        Department.find_each do |department|
          Stats::MonthlyStats::UpsertStatJob.perform_later("Department", department.id, Time.zone.now)
        end

        Organisation.find_each do |organisation|
          Stats::MonthlyStats::UpsertStatJob.perform_later("Organisation", organisation.id, Time.zone.now)
        end
      end
    end
  end
end
