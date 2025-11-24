describe FollowUps::PlanStatusRefreshJob do
  subject do
    described_class.new.perform(follow_up_id)
  end

  let!(:follow_up_id) { 23 }
  let!(:follow_up) { create(:follow_up, id: follow_up_id) }
  let!(:refresh_status_at) { 10.days.from_now }

  describe "#perform" do
    before do
      allow(FollowUp).to receive(:find).with(follow_up_id).and_return(follow_up)
      allow(follow_up).to receive(:refresh_status_at).and_return(refresh_status_at)
    end

    it "plans a status refresh job" do
      expect(Sidekiq::Scheduler).to receive(:schedule_uniq_job)
        .with(FollowUps::RefreshStatusesJob, follow_up_id,
              at: refresh_status_at)
      subject
    end

    context "when the refresh status at is nil" do
      before do
        allow(follow_up).to receive(:refresh_status_at).and_return(nil)
      end

      it "does nothing" do
        expect(Sidekiq::Scheduler).not_to receive(:schedule_uniq_job)
        subject
      end
    end

    context "when the refresh status at is in the past" do
      before do
        allow(follow_up).to receive(:refresh_status_at).and_return(1.hour.ago)
      end

      it "does nothing" do
        expect(Sidekiq::Scheduler).not_to receive(:schedule_uniq_job)
        subject
      end
    end
  end
end
