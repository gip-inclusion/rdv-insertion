describe RefreshRdvContextStatusesJob do
  subject do
    described_class.new.perform(rdv_context_ids)
  end

  let!(:rdv_context_ids) { [23] }
  let!(:rdv_context) { create(:rdv_context) }

  describe "#perform" do
    before do
      allow(RdvContext).to receive_messages(includes: RdvContext, where: [rdv_context])
      allow(rdv_context).to receive(:set_status)
      allow(rdv_context).to receive(:save!)
    end

    it "retrieves the users" do
      expect(RdvContext).to receive(:where)
        .with(id: rdv_context_ids)
      subject
    end

    it "sets the status and saves" do
      expect(rdv_context).to receive(:set_status)
      expect(rdv_context).to receive(:save!)
      subject
    end
  end
end
