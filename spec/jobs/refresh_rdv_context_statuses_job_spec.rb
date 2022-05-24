describe RefreshRdvContextStatusesJob, type: :job do
  subject do
    described_class.new.perform(rdv_context_ids)
  end

  let!(:rdv_context_ids) { [23] }
  let!(:rdv_context) { create(:rdv_context) }

  describe "#perform" do
    before do
      allow(RdvContext).to receive(:includes)
        .and_return(RdvContext)
      allow(RdvContext).to receive(:where)
        .and_return([rdv_context])
      allow(rdv_context).to receive(:set_status)
      allow(rdv_context).to receive(:save!)
    end

    it "retrieves the applicants" do
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
