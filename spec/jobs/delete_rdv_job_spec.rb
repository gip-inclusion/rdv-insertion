describe DeleteRdvJob, type: :job do
  subject do
    described_class.new.perform(rdv_solidarites_rdv_id)
  end

  let!(:rdv_solidarites_rdv_id) { { id: 1 } }
  let!(:rdv) { create(:rdv, participations: [participation]) }
  let!(:participation) { create(:participation, rdv_context: rdv_context) }
  let!(:rdv_context) { create(:rdv_context) }

  describe "#perform" do
    before do
      allow(Rdv).to receive(:find_by)
        .with(rdv_solidarites_rdv_id: rdv_solidarites_rdv_id)
        .and_return(rdv)
      allow(rdv).to receive(:destroy!)
      allow(RefreshRdvContextStatusesJob).to receive(:perform_async)
    end

    it "finds the matching rdv" do
      expect(Rdv).to receive(:find_by)
        .with(rdv_solidarites_rdv_id: rdv_solidarites_rdv_id)
      subject
    end

    it "destroys the rdv" do
      expect(rdv).to receive(:destroy!)
      subject
    end

    it "enqueues a refresh status job" do
      expect(RefreshRdvContextStatusesJob).to receive(:perform_async)
        .with([rdv_context.id])
      subject
    end
  end
end
