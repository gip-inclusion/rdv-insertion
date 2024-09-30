RSpec.describe LockedJobs, type: :concern do
  let(:dummy_class) do
    Class.new(ApplicationJob) do
      include LockedJobs

      def self.lock_key(id)
        "test_lock_#{id}"
      end

      def perform(_id)
        sleep 0.2
      end
    end
  end

  describe "locking behavior", :no_transaction do
    it "prevents parallel execution of jobs with the same lock_key" do
      thread1 = Thread.new { dummy_class.perform_now(1) }
      thread1.report_on_exception = false

      thread2 = Thread.new { dummy_class.perform_now(1) }
      thread2.report_on_exception = false

      expect do
        [thread1, thread2].each(&:join)
      end.to raise_error(WithAdvisoryLock::FailedToAcquireLock)
    end

    it "allows parallel execution of jobs with different lock_keys" do
      thread1 = Thread.new { dummy_class.perform_now(1) }
      thread2 = Thread.new { dummy_class.perform_now(2) }

      expect do
        [thread1, thread2].each(&:join)
      end.not_to raise_error
    end
  end
end
