module LockedAndOrderedJobs
  extend ActiveSupport::Concern
  # This will wrap the hook inside the perform_with_lock method
  prepend LockedJobs

  CACHED_TIMESTAMP_EXPIRATION_TIME = 30.minutes

  included do
    around_perform :perform_in_order
  end

  private

  def perform_in_order
    RedisConnection.with_redis do |redis|
      cache_key = self.class.lock_key(*arguments)
      cached_timestamp = redis.get(cache_key)
      job_timestamp = self.class.job_timestamp(*arguments)

      next if cached_timestamp.present? && cached_timestamp.to_datetime > job_timestamp.to_datetime

      yield

      redis.set(cache_key, job_timestamp.to_s, ex: CACHED_TIMESTAMP_EXPIRATION_TIME)
    end
  end

  class_methods do
    def job_timestamp(_job_args)
      raise NoMethodError
    end
  end
end
