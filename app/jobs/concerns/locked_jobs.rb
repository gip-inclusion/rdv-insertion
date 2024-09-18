module LockedJobs
  extend ActiveSupport::Concern
  # We wait 3 seconds for the lock to be released
  # if it's not released, we raise an WithAdvisoryLock::FailedToAcquireLockError
  TIMEOUT_SECONDS = 3

  included do
    around_perform :perform_with_lock
  end

  private

  def perform_with_lock(&block)
    ActiveRecord::Base.with_advisory_lock!(
      self.class.lock_key(*arguments), timeout_seconds: TIMEOUT_SECONDS, &block
    )
  end

  class_methods do
    def lock_key(_job_args)
      raise NoMethodError
    end
  end
end
