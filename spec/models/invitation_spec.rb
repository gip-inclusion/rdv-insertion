describe Invitation do
  describe "#valid?" do
    let!(:department) { create(:department) }
    let!(:organisation) { create(:organisation, department: department) }
    let!(:user) { create(:user) }
    let!(:rdv_context) { build(:rdv_context) }
    let!(:invitation) do
      build(
        :invitation,
        organisations: [organisation], department: department, rdv_context: rdv_context,
        help_phone_number: "0101010101", user: user, rdv_solidarites_token: "rdv_solidarites_token",
        link: "https://www.rdv-solidarites.fr"
      )
    end

    it { expect(invitation).to be_valid }

    context "when no rdv_solidarites_token" do
      before { invitation.rdv_solidarites_token = nil }

      it { expect(invitation).not_to be_valid }
    end

    context "when no link" do
      before { invitation.link = nil }

      it { expect(invitation).not_to be_valid }
    end

    context "when no help_phone_number" do
      before { invitation.help_phone_number = nil }

      it { expect(invitation).not_to be_valid }
    end

    context "when no organisations" do
      before { invitation.organisations = [] }

      it { expect(invitation).not_to be_valid }
    end
  end

  describe "sends webhook" do
    let!(:invitation) { build(:invitation, sent_at: nil, organisations: [organisation]) }
    let!(:organisation) { create(:organisation) }
    let!(:webhook_endpoint) { create(:webhook_endpoint, organisations: [organisation], subscriptions: ["invitation"]) }

    it "does not send a webhook if the invitation is not sent" do
      expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_async)
      invitation.save
    end

    it "sends a webhook if the invitation is sent" do
      invitation.sent_at = Time.zone.now
      expect(OutgoingWebhooks::SendWebhookJob).to receive(:perform_async)
      invitation.save
    end
  end
end
