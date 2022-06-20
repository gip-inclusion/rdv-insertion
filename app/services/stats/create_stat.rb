module Stats
  class CreateStat < BaseService
    def initialize(department_number:)
      @department_number = department_number
    end

    def call
      result.stat = stat
      assign_stats_to_stat_record
      save_record!(stat)
    end

    private

    def stat
      @stat ||= Stat.find_or_initialize_by(department_number: @department_number)
    end

    def assign_stats_to_stat_record
      stat.assign_attributes(compute_stats.data)
    end

    def compute_stats
      @compute_stats ||= Stats::ComputeStats.call(department_number: @department_number)
    end
  end
end
