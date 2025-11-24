describe Sidekiq::Scheduler do
  let!(:job_class) { FollowUps::RefreshStatusesJob }
  let!(:args) { [23] }
  let!(:at) { 1.hour.from_now }

  describe "#schedule_uniq_job" do
    subject do
      described_class.schedule_uniq_job(job_class, *args, at: at)
    end

    around do |example|
      with_sidekiq_enabled { example.run }
    end

    context "when the job does not exist" do
      it "schedules a job" do
        subject

        scheduled_set = Sidekiq::ScheduledSet.new
        expect(scheduled_set.size).to eq(1)
        expect(scheduled_set.first.display_class).to eq(job_class.to_s)
        expect(scheduled_set.first.display_args).to eq(args)
        expect(scheduled_set.first.queue).to eq("default")
        expect(scheduled_set.first.at.to_i).to eq(at.to_i)
      end
    end

    context "when the job already exists" do
      let!(:old_time) { 30.minutes.from_now }

      before do
        job_class.set(wait_until: old_time, queue: "default")
                 .perform_later(*args)
      end

      it "reschedules the job to the new time" do
        scheduled_set = Sidekiq::ScheduledSet.new
        expect(scheduled_set.size).to eq(1)
        expect(scheduled_set.first.at.to_i).to eq(old_time.to_i)

        subject

        expect(scheduled_set.size).to eq(1)
        expect(scheduled_set.first.display_class).to eq(job_class.to_s)
        expect(scheduled_set.first.display_args).to eq(args)
        expect(scheduled_set.first.queue).to eq("default")
        expect(scheduled_set.first.at.to_i).to eq(at.to_i)
      end
    end
  end
end
