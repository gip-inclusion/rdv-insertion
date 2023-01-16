describe InvalidateInvitationJob do
  subject do
    described_class.new.perform(invitation_id)
  end

  let!(:invitation_id) { 444 }
  let!(:invitation) { create(:invitation, id: invitation_id) }

  describe "#perform" do
    before do
      allow(Invitations::InvalidateLink).to receive(:call)
        .with(invitation: invitation)
        .and_return(OpenStruct.new(success?: true))
    end

    it "calls a InvalidateLink service" do
      expect(Invitations::InvalidateLink).to receive(:call)
        .with(invitation: invitation)
      subject
    end

    context "when the invitation is expired" do
      let!(:invitation) { create(:invitation, id: invitation_id, valid_until: 1.day.ago) }

      it "does not call a InvalidateLink service" do
        expect(Invitations::InvalidateLink).not_to receive(:call)
        subject
      end
    end
  end
end
