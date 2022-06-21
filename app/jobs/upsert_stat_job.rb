class StatsJobError < StandardError; end

class UpsertStatJob < ApplicationJob
  def perform(department_number)
    upsert_stat_record = Stats::UpsertStat.call(department_number: department_number)

    raise StatsJobError, upsert_stat_record.errors.join(" - ") unless upsert_stat_record.success?
  end
end
