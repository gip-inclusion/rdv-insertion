module LockedAndOrderedJobs
  extend ActiveSupport::Concern
  # jobs need to implement the lock_key method
  prepend LockedJobs

  CACHED_TIMESTAMP_EXPIRATION_TIME = 5.minutes

  included do
    around_perform do |job, block|
      perform_in_order(job.arguments) do
        block.call
      end
    end
  end

  private

  def perform_in_order(job_args, &block)
    with_redis_connection_pool do |redis|
      cache_key = self.class.lock_key(*job_args)
      cached_timestamp = redis.get(cache_key)
      job_timestamp = self.class.job_timestamp(*job_args)

      next if cached_timestamp.present? && cached_timestamp.to_datetime > job_timestamp.to_datetime

      block.call

      redis.set(cache_key, job_timestamp, ex: CACHED_TIMESTAMP_EXPIRATION_TIME)
    end
  end

  class_methods do
    def job_timestamp(_job_args)
      raise NoMethodError
    end
  end
end
