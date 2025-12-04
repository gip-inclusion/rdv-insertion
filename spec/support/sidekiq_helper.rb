module SidekiqHelper
  def with_sidekiq_enabled
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :sidekiq

    Sidekiq::Testing.disable! do
      Sidekiq.redis(&:flushdb)
      yield
      Sidekiq.redis(&:flushdb)
    end
  ensure
    ActiveJob::Base.queue_adapter = original_adapter
  end
end
