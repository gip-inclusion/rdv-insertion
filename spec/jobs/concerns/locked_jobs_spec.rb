RSpec.describe LockedJobs, type: :concern do
  let(:dummy_class) do
    Class.new(ApplicationJob) do
      include LockedJobs

      def self.lock_key(id, _duration)
        "test_lock_#{id}"
      end

      def perform(id, shared_array)
        shared_array << "start #{id}"
        sleep 0.1
        shared_array << "end #{id}"
      end
    end
  end

  describe "locking behavior", :no_transaction do
    it "prevents parallel execution of jobs with the same lock_key" do
      shared_array = []

      thread1 = Thread.new { dummy_class.perform_now(1, shared_array) }
      thread2 = Thread.new { dummy_class.perform_now(1, shared_array) }

      [thread1, thread2].each(&:join)

      # the jobs executed sequentially
      expect(shared_array).to eq(["start 1", "end 1", "start 1", "end 1"])
    end

    it "allows parallel execution of jobs with different lock_keys" do
      shared_array = []

      thread1 = Thread.new { dummy_class.perform_now(1, shared_array) }
      thread2 = Thread.new { dummy_class.perform_now(2, shared_array) }

      [thread1, thread2].each(&:join)
      # The exact order might vary, but the second job should start before the first job ends
      expect(shared_array.uniq.length).to eq(4)
      expect(shared_array.index("start 1")).to be < shared_array.index("end 1")
      expect(shared_array.index("start 2")).to be < shared_array.index("end 1")
    end
  end
end
