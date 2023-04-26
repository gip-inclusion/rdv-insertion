describe SendConvocationRemindersJob do
  subject do
    described_class.new.perform
  end

  describe "#perform" do
    let!(:participation1) { create(:participation, id: 239) }
    let!(:participation2) { create(:participation) }
    let!(:participation3) { create(:participation) }

    let!(:rdv1) { create(:rdv, starts_at: 2.days.from_now, convocable: true, participations: [participation1]) }
    let!(:rdv2) { create(:rdv, starts_at: 2.days.from_now, convocable: false, participations: [participation2]) }
    let!(:rdv3) { create(:rdv, starts_at: 3.days.from_now, convocable: true, participations: [participation3]) }

    before do
      allow(NotifyParticipationsJob).to receive(:perform_async)
      allow(MattermostClient).to receive(:send_to_notif_channel)
    end

    it "notifies the convocable participation that starts in 2 days" do
      expect(NotifyParticipationsJob).to receive(:perform_async)
        .with([239], "reminder")
      subject
    end

    it "sends a notification to mattermost" do
      expect(MattermostClient).to receive(:send_to_notif_channel)
        .with(
          "📅 1 rappels de convocation en cours d'envoi!\n" \
          "Les participations sont: [239]"
        )
      subject
    end
  end
end
