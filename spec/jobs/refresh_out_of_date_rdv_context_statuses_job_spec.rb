describe RefreshOutOfDateRdvContextStatusesJob do
  subject do
    described_class.new.perform
  end

  # status out of date
  let!(:participation1) { create(:participation, status: "unknown", rdv_context: rdv_context1) }
  let!(:rdv1) { create(:rdv, starts_at: 1.day.ago, participations: [participation1]) }
  let!(:rdv_context1) { create(:rdv_context, status: "rdv_pending", id: 1) }

  # ok
  let!(:rdv_context2) { create(:rdv_context, status: "not_invited", id: 2) }

  # status out of date
  let!(:rdv_context3) { create(:rdv_context, status: "invitation_pending", id: 3) }
  let!(:invitation) { create(:invitation, sent_at: 3.days.ago) }
  let!(:rdv3) { create(:rdv, participations: [participation3]) }
  let!(:participation3) { create(:participation, created_at: 2.days.ago, status: "unknown", rdv_context: rdv_context3) }

  # ok
  let!(:rdv_context4) { create(:rdv_context, status: "rdv_seen", id: 4) }
  let!(:rdv4) do
    create(:rdv, starts_at: 1.day.ago, participations: [participation4])
  end
  let!(:participation4) { create(:participation, rdv_context: rdv_context4, status: "seen") }

  # status out of date
  let!(:rdv_context5) { create(:rdv_context, status: "rdv_pending", id: 5) }
  let!(:rdv5) { create(:rdv, starts_at: 1.day.ago, participations: [participation5]) }
  let!(:participation5) { create(:participation, status: "seen", rdv_context: rdv_context5) }

  describe "#perform" do
    before do
      # remove rdv contexts created in callbacks
      RdvContext.where.not(id: [1, 2, 3, 4, 5]).each(&:destroy!)
      allow(RefreshRdvContextStatusesJob).to receive(:perform_async)
      allow(MattermostClient).to receive(:send_to_notif_channel)
      allow(ENV).to receive(:[]).with("SENTRY_ENVIRONMENT").and_return("production")
    end

    it "enqueues a refresh job for out of date rdv contexts" do
      expect(RefreshRdvContextStatusesJob).to receive(:perform_async)
        .with([1, 3, 5])
      subject
    end

    it "sends a notification on mattermost" do
      expect(MattermostClient).to receive(:send_to_notif_channel)
        .with(
          "✨ Rafraîchit les statuts pour: [1, 3, 5]"
        )
      subject
    end
  end
end
