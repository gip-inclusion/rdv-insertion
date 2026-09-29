describe AlertMotifCategoryHasChangedJob do
  subject { described_class.new.perform(motif_id) }

  let(:motif_id) { motif.id }
  let(:motif) { create(:motif) }

  describe "#perform" do
    context "when motif has rdvs" do
      let!(:rdv) { create(:rdv, motif: motif) }

      it "sends a message to slack" do
        expect(SlackClient).to receive(:send_to_private_channel).with(
          "⚠️ Le motif #{motif.name} (ID rdv-sp: #{motif.rdv_solidarites_motif_id}) de l'organisation" \
          " #{motif.organisation.name} (ID rdv-sp: #{motif.organisation.rdv_solidarites_organisation_id}) vient de" \
          " changer de catégorie malgré la présence de #{motif.rdvs.count} rendez-vous associés."
        )

        subject
      end
    end

    context "when motif has no rdvs" do
      it "does not send a message to slack" do
        expect(SlackClient).not_to receive(:send_to_private_channel)

        subject
      end
    end
  end
end
