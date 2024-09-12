module Stats
  module MonthlyStats
    class UpsertStatsJob < ApplicationJob
      sidekiq_options queue: :stats

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
