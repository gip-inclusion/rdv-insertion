module LockedJobs
  extend ActiveSupport::Concern
  # We wait 3 seconds for the lock to be released
  # if it's not released, we raise an WithAdvisoryLock::FailedToAcquireLockError
  DEFAULT_TIMEOUT_SECONDS = 2

  included do
    around_perform :perform_with_lock
  end

  private

  def perform_with_lock(&block)
    ActiveRecord::Base.with_advisory_lock!(
      self.class.lock_key(*arguments), timeout_seconds: self.class.lock_timeout_seconds, &block
    )
  end

  class_methods do
    def lock_key(_job_args)
      raise NoMethodError
    end

    def lock_timeout_seconds
      # we leave the possibility to set the timeout to 0 to not block our workers
      # in case lot of jobs with the same lock key are enqueued somehow.
      # In this case the jobs will fail after one unsuccessful attempt to acquire the lock.
      (ENV["JOB_LOCK_TIMEOUT_SECONDS"] || DEFAULT_TIMEOUT_SECONDS).to_i
    end
  end
end
