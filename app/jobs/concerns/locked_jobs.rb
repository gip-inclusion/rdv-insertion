module LockedJobs
  extend ActiveSupport::Concern

  included do
    around_perform :perform_with_lock
  end

  private

  def perform_with_lock(&)
    # if the lock is not available, we raise an WithAdvisoryLock::FailedToAcquireLockError
    # and the job will be retried
    ActiveRecord::Base.with_advisory_lock!(
      self.class.lock_key(*arguments), timeout_seconds: 0, &
    )
  rescue WithAdvisoryLock::FailedToAcquireLock
    self.class.on_lock_failure(*arguments) if self.class.respond_to?(:on_lock_failure)
    raise
  end

  class_methods do
    def lock_key(_job_args)
      raise NoMethodError
    end
  end
end
