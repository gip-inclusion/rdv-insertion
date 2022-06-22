class UpsertStatsJob < ApplicationJob
  def perform
    department_numbers = Department.pluck(:number).push("all")
    department_numbers.each do |department_number|
      UpsertStatJob.perform_async(department_number)
    end
  end
end
