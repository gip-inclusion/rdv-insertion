describe AlertMotifCategoryHasChangedJob do
  subject { described_class.new.perform(motif_id) }

  let(:motif_id) { motif.id }
  let(:motif) { create(:motif) }

  describe "#perform" do
    context "when motif has rdvs" do
      let!(:rdv) { create(:rdv, motif: motif) }

      it "sends a message to Mattermost and Sentry" do
        expect(MattermostClient).to receive(:send_to_notif_channel)
        expect(Sentry).to receive(:capture_message)

        subject
      end
    end

    context "when motif has no rdvs" do
      it "does not send a message to Mattermost and Sentry" do
        expect(MattermostClient).not_to receive(:send_to_notif_channel)
        expect(Sentry).not_to receive(:capture_message)

        subject
      end
    end
  end
end
