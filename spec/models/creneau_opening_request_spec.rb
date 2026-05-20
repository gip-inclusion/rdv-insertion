describe CreneauOpeningRequest do
  describe "validations" do
    let(:creneau_opening_request) { build(:creneau_opening_request) }

    it { expect(creneau_opening_request).to be_valid }

    context "without a link" do
      before { creneau_opening_request.link = nil }

      it { expect(creneau_opening_request).not_to be_valid }
    end

    context "without users_to_invite_count" do
      before { creneau_opening_request.users_to_invite_count = nil }

      it { expect(creneau_opening_request).not_to be_valid }
    end

    context "with a negative users_to_invite_count" do
      before { creneau_opening_request.users_to_invite_count = -1 }

      it { expect(creneau_opening_request).not_to be_valid }
    end

    context "without available_creneaux_count" do
      before { creneau_opening_request.available_creneaux_count = nil }

      it { expect(creneau_opening_request).not_to be_valid }
    end

    context "with a duplicate uuid" do
      before do
        existing = create(:creneau_opening_request)
        creneau_opening_request.uuid = existing.uuid
      end

      it { expect(creneau_opening_request).not_to be_valid }
    end
  end

  describe "after_commit on create" do
    it "enqueues the send-email job" do
      expect(CreneauOpeningRequests::SendEmailJob).to receive(:perform_later)

      create(:creneau_opening_request)
    end
  end
end
