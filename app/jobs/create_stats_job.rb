class CreateStatsJob < ApplicationJob
  def perform
    department_ids = Department.all.collect(&:id).push(nil)
    department_ids.each do |department_id|
      CreateStat.call(department_id)
    end
  end
end
