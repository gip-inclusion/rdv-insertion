module Stats
  module GlobalStats
    class UpsertStatsJob < ApplicationJob
      def perform
        Stats::GlobalStats::UpsertStatJob.perform_async("Department", nil)

        Department.find_each do |department|
          Stats::GlobalStats::UpsertStatJob.perform_async("Department", department.id)
        end

        Organisation.find_each do |organisation|
          Stats::GlobalStats::UpsertStatJob.perform_async("Organisation", organisation.id)
        end
      end
    end
  end
end
