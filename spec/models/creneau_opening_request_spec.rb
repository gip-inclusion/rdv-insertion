describe CreneauOpeningRequest do
  describe "uuid uniqueness" do
    let(:creneau_opening_request) { build(:creneau_opening_request) }

    before do
      existing = create(:creneau_opening_request)
      creneau_opening_request.uuid = existing.uuid
    end

    it { expect(creneau_opening_request).not_to be_valid }
  end

  describe "after_commit on create" do
    it "enqueues the send-email job" do
      expect(CreneauOpeningRequests::SendEmailJob).to receive(:perform_later)

      create(:creneau_opening_request)
    end
  end
end
