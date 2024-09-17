module LockedJobs
  extend ActiveSupport::Concern
  # we wait 5 seconds for the lock to be released
  # if it's not released, we raise an WithAdvisoryLock::FailedToAcquireLockError
  TIMEOUT_SECONDS = 5

  included do
    around_perform do |job, block|
      perform_with_lock(job.arguments) do
        block.call
      end
    end
  end

  private

  def perform_with_lock(job_args, &block)
    ActiveRecord::Base.with_advisory_lock!(
      self.class.lock_key(*job_args), timeout_seconds: TIMEOUT_SECONDS, &block
    )
  end

  class_methods do
    def lock_key(_job_args)
      raise NoMethodError
    end
  end
end
