describe Invitations::InvalidateToken, type: :service do
  subject do
    described_class.call(invitation: invitation)
  end

  let!(:invitation) { create(:invitation, valid_until: 3.days.from_now) }

  describe "#call" do
    before do
      allow(invitation).to receive(:save)
        .and_return(true)
    end

    it "is a success" do
      is_a_success
    end

    it "saves an invitation" do
      expect(invitation).to receive(:save)
      subject
    end

    it "returns an invitation" do
      expect(subject.invitation).to eq(invitation)
    end

    it "updates valid_until" do
      expect(subject.invitation.valid_until.to_date).to eq(Time.zone.today)
      subject
    end

    context "when it fails to save" do
      before do
        allow(invitation).to receive(:save)
          .and_return(false)
      end

      it "is a failure" do
        is_a_failure
      end
    end
  end
end
