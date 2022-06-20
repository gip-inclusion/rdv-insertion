class StatsJobError < StandardError; end

class CreateStatsJob < ApplicationJob
  def perform
    department_numbers = Department.pluck(:number).push("all")
    department_numbers.each do |department_number|
      upsert_stat_record = Stats::CreateStat.call(department_number: department_number)

      raise StatsJobError, upsert_stat_record.errors.join(" - ") unless upsert_stat_record.success?
    end
  end
end
