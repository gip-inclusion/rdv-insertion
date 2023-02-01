class UpsertGlobalStatsJob < ApplicationJob
  def perform
    department_numbers = Department.pluck(:number).push("all")
    department_numbers.each do |department_number|
      GlobalStats::UpsertStatJob.perform_async(department_number)
    end
  end
end
