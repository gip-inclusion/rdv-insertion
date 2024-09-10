describe ExpireInvitationJob do
  subject do
    described_class.new.perform(invitation_id)
  end

  let!(:invitation_id) { 444 }
  let!(:invitation) { create(:invitation, id: invitation_id, expires_at: 1.day.from_now) }
  let!(:now) { Time.zone.parse("05/10/2022") }

  before { travel_to now }

  describe "#perform" do
    it "expires the invitation" do
      subject

      expect(invitation.reload.expires_at).to eq(now)
    end

    context "when the invitation is expired" do
      let!(:expired_at) { Time.zone.parse("04/10/2022") }
      let!(:invitation) { create(:invitation, id: invitation_id, expires_at: expired_at) }

      it "does nothing" do
        subject

        expect(invitation.reload.expires_at).to eq(expired_at)
      end
    end
  end
end
