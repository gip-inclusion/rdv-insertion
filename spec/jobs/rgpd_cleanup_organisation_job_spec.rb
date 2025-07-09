describe RgpdCleanupOrganisationJob do
  subject do
    described_class.perform_now(organisation.id)
  end

  let(:organisation) { create(:organisation) }

  describe "#perform" do
    it "calls the RgpdCleanUp with the organisation" do
      expect(Organisations::RgpdCleanup).to receive(:call).with(organisation: organisation)
      subject
    end
  end
end
