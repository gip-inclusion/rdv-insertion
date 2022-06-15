module Stats
  class CreateStat < BaseService
    def initialize(department_id:)
      @department_id = department_id
    end

    def call
      save_record!(stat)
      result.stat = stat
    end

    private

    def stat
      @stat ||= Stat.new(stats.data)
    end

    def stats
      @stats ||= Stats::ComputeStats.call(department_id: @department_id)
    end
  end
end
