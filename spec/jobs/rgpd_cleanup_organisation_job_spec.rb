describe RgpdCleanupOrganisationJob do
  subject do
    described_class.perform_now(organisation.id)
  end

  let(:organisation) { create(:organisation) }

  before do
    allow(Organisations::RgpdCleanup).to receive(:call).with(organisation:).and_return(OpenStruct.new(success?: true))
  end

  describe "#perform" do
    it "calls the RgpdCleanUp with the organisation" do
      subject
      expect(Organisations::RgpdCleanup).to have_received(:call).with(organisation:)
    end
  end
end
