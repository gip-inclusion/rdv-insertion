describe AlertMotifCategoryHasChangedJob do
  subject { described_class.new.perform(motif_id) }

  let(:motif_id) { motif.id }
  let(:motif) { create(:motif) }

  describe "#perform" do
    context "when motif has rdvs" do
      let!(:rdv) { create(:rdv, motif: motif) }

      it "sends a message to Mattermost and Sentry" do
        expect(MattermostClient).to receive(:send_to_private_channel).with(
          "⚠️ Le motif #{motif.name} (ID rdv-sp: #{motif.rdv_solidarites_motif_id}) de l'organisation" \
          " #{motif.organisation.name} (ID rdv-sp: #{motif.organisation.rdv_solidarites_organisation_id}) vient de" \
          " changer de catégorie malgré la présence de #{motif.rdvs.count} rendez-vous associés."
        )
        expect(Sentry).to receive(:capture_message)

        subject
      end
    end

    context "when motif has no rdvs" do
      it "does not send a message to Mattermost and Sentry" do
        expect(MattermostClient).not_to receive(:send_to_private_channel)
        expect(Sentry).not_to receive(:capture_message)

        subject
      end
    end
  end
end
