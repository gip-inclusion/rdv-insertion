module Stats
  module GlobalStats
    class UpsertStatsJob < ApplicationJob
      def perform
        department_numbers = Department.pluck(:number).push("all")
        department_numbers.each do |department_number|
          Stats::GlobalStats::UpsertStatJob.perform_async(department_number)
        end
      end
    end
  end
end
