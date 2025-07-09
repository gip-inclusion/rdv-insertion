describe RgpdCleanupJob do
  describe "#perform" do
    let!(:organisation1) { create(:organisation, data_retention_duration: 12) }
    let!(:organisation2) { create(:organisation, data_retention_duration: 24) }

    it "enqueues RgpdCleanupOrganisationJob for each organisation" do
      allow(RgpdCleanupOrganisationJob).to receive(:perform_later)

      described_class.perform_now

      expect(RgpdCleanupOrganisationJob).to have_received(:perform_later).with(organisation1.id)
      expect(RgpdCleanupOrganisationJob).to have_received(:perform_later).with(organisation2.id)
    end
  end
end
