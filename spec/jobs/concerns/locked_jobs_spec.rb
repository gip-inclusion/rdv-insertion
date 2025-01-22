RSpec.describe LockedJobs, type: :concern do
  let(:dummy_class) do
    Class.new(ApplicationJob) do
      include LockedJobs

      def self.lock_key(id)
        "test_lock_#{id}"
      end

      def perform(_id)
        sleep 0.1
      end
    end
  end

  after do
    # Ensure all connections are returned to the pool and locks are released
    ActiveRecord::Base.connection_pool.clear_reloadable_connections!
  end

  describe "locking behavior with same lock_key", :no_transaction do
    it "prevents parallel execution of jobs with the same lock_key" do
      exceptions = []

      thread1 = Thread.new do
        # this ensures the thread release its database connections properly so that locks don't persist
        # beyond the test
        ActiveRecord::Base.connection_pool.with_connection do
          dummy_class.perform_now(1)
        rescue StandardError => e
          exceptions << e
        end
      end

      thread2 = Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          dummy_class.perform_now(1)
        rescue StandardError => e
          exceptions << e
        end
      end

      [thread1, thread2].each(&:join)

      # Expect one of the threads to raise a FailedToAcquireLock error
      expect(exceptions.size).to eq(1)
      expect(exceptions.first).to be_a(WithAdvisoryLock::FailedToAcquireLock)
    end
  end

  describe "no locking behavior with different lock_key", :no_transaction do
    it "allows parallel execution of jobs with different lock_keys" do
      exceptions = []

      thread1 = Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          dummy_class.perform_now(1)
        rescue StandardError => e
          exceptions << e
        end
      end

      thread2 = Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          dummy_class.perform_now(2)
        rescue StandardError => e
          exceptions << e
        end
      end

      [thread1, thread2].each(&:join)

      # Expect no errors since locks are different
      expect(exceptions).to be_empty
    end
  end
end
