require "rails_helper"

class TestJob < ApplicationJob
  include LockedAndOrderedJobs

  def self.lock_key(*args)
    "test_job:#{args.join(':')}"
  end

  def self.job_timestamp(*_args)
    Time.zone.now
  end

  def perform(*args)
    # Simulate job execution
  end
end

RSpec.describe LockedAndOrderedJobs do
  let(:redis) { Redis.new }
  let(:job) { TestJob.new }

  before do
    allow(Redis).to receive(:new).and_return(redis)
  end

  describe "#perform_in_order" do
    it "executes the job when no cached timestamp exists" do
      expect(job).to receive(:perform).with("arg1", "arg2")
      job.send(:perform_in_order, %w[arg1 arg2]) { job.perform("arg1", "arg2") }
    end

    it "skips execution when cached timestamp is newer" do
      future_time = 1.hour.from_now
      redis.set(TestJob.lock_key("arg1", "arg2"), future_time.to_s, ex: 300)

      expect(job).not_to receive(:perform)
      job.send(:perform_in_order, %w[arg1 arg2]) { job.perform("arg1", "arg2") }
    end

    it "executes the job when cached timestamp is older" do
      past_time = 1.hour.ago
      redis.set(TestJob.lock_key("arg1", "arg2"), past_time.to_s, ex: 300)

      expect(job).to receive(:perform).with("arg1", "arg2")
      job.send(:perform_in_order, %w[arg1 arg2]) { job.perform("arg1", "arg2") }
    end

    it "sets the cache key after execution" do
      job.send(:perform_in_order, %w[arg1 arg2]) { job.perform("arg1", "arg2") }
      expect(redis.get(TestJob.lock_key("arg1", "arg2"))).to be_present
    end
  end
end
