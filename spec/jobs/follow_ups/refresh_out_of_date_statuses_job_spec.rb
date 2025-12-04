describe FollowUps::RefreshOutOfDateStatusesJob do
  subject do
    described_class.new.perform
  end

  # status out of date
  let!(:participation1) { create(:participation, status: "unknown", follow_up: follow_up1) }
  let!(:rdv1) { create(:rdv, starts_at: 1.day.ago, participations: [participation1]) }
  let!(:follow_up1) { create(:follow_up, status: "rdv_pending") }

  # ok
  let!(:follow_up2) { create(:follow_up, status: "not_invited") }

  # status out of date
  let!(:follow_up3) { create(:follow_up, status: "invitation_pending") }
  let!(:invitation) { create(:invitation, created_at: 3.days.ago) }
  let!(:rdv3) { create(:rdv, participations: [participation3]) }
  let!(:participation3) { create(:participation, created_at: 2.days.ago, status: "unknown", follow_up: follow_up3) }

  # ok
  let!(:follow_up4) { create(:follow_up, status: "rdv_seen") }
  let!(:rdv4) do
    create(:rdv, starts_at: 1.day.ago, participations: [participation4])
  end
  let!(:participation4) { create(:participation, follow_up: follow_up4, status: "seen") }

  # status out of date
  let!(:follow_up5) { create(:follow_up, status: "rdv_pending") }
  let!(:rdv5) { create(:rdv, starts_at: 1.day.ago, participations: [participation5]) }
  let!(:participation5) { create(:participation, status: "seen", follow_up: follow_up5) }

  describe "#perform" do
    before do
      # remove follow-ups created in callbacks
      FollowUp.where.not(id: [follow_up1.id, follow_up2.id, follow_up3.id, follow_up4.id,
                              follow_up5.id]).find_each(&:destroy!)
      allow(FollowUps::RefreshStatusesJob).to receive(:perform_later)
      allow(SlackClient).to receive(:send_to_notif_channel)
    end

    it "enqueues a refresh job for out of date follow-ups" do
      expect(FollowUps::RefreshStatusesJob).to receive(:perform_later)
        .with([follow_up1.id, follow_up3.id, follow_up5.id])
      subject
    end

    it "sends a notification on slack" do
      expect(SlackClient).to receive(:send_to_notif_channel)
        .with(
          "✨ Rafraîchit les statuts pour: [#{follow_up1.id}, #{follow_up3.id}, #{follow_up5.id}]"
        )
      subject
    end
  end
end
