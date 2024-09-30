class TestJob < ApplicationJob
  include LockedAndOrderedJobs

  def self.lock_key(*args)
    "test_job:#{args[0..1].join(':')}"
  end

  def self.job_timestamp(*args)
    args.last
  end

  def perform(*args); end
end

RSpec.describe LockedAndOrderedJobs do
  let!(:redis) { Redis.new }

  before do
    allow(Redis).to receive(:new).and_return(redis)
  end

  after do
    redis.flushdb
  end

  describe ".perform_now" do
    let(:current_time) { Time.zone.now }

    it "executes the job when no cached timestamp exists" do
      expect_any_instance_of(TestJob).to receive(:perform).with("arg1", "arg2", current_time)
      TestJob.perform_now("arg1", "arg2", current_time)
    end

    it "skips execution when cached timestamp is newer" do
      future_time = 1.hour.from_now
      redis.set(TestJob.lock_key("arg1", "arg2"), future_time.to_s, ex: 300)

      expect_any_instance_of(TestJob).not_to receive(:perform)
      TestJob.perform_now("arg1", "arg2", current_time)
    end

    it "executes the job when cached timestamp is older" do
      past_time = 1.hour.ago
      redis.set(TestJob.lock_key("arg1", "arg2"), past_time.to_s, ex: 300)

      expect_any_instance_of(TestJob).to receive(:perform).with("arg1", "arg2", current_time)
      TestJob.perform_now("arg1", "arg2", current_time)
    end

    it "sets the cache key after execution" do
      TestJob.perform_now("arg1", "arg2", current_time)
      expect(redis.get(TestJob.lock_key("arg1", "arg2"))).to eq(current_time.to_s)
    end

    it "locks the job execution" do
      expect(ActiveRecord::Base).to receive(:with_advisory_lock!).with(
        "test_job:arg1:arg2",
        timeout_seconds: 0
      )

      TestJob.perform_now("arg1", "arg2", current_time)
    end
  end
end
