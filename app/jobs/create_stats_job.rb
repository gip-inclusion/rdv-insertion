class CreateStatsJob < ApplicationJob
  def perform
    department_ids = Department.pluck(:id).push(nil)
    department_ids.each do |department_id|
      Stats::CreateStat.call(department_id: department_id)
    end
  end
end
