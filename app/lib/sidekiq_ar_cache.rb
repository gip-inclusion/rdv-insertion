class SidekiqArCache
  def call(worker, msg, queue)
    ActiveRecord::Base.uncached do
      yield
    end
  end
end
