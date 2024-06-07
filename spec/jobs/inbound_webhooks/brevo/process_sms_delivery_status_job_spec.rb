describe InboundWebhooks::Brevo::ProcessSmsDeliveryStatusJob do
  subject { described_class.new.perform(webhook_params, invitation_id) }

  let(:webhook_params) { { to: "0601010101", msg_status: "delivered", date: "2023-06-07T12:34:56Z" } }
  let!(:invitation) { create(:invitation) }
  let(:invitation_id) { invitation.id }

  before do
    allow(Sentry).to receive(:capture_message)
  end

  it "processes SMS delivery status" do
    expect(Invitations::AssignSmsDeliveryStatusAndDate).to receive(:call)
      .with(webhook_params: webhook_params, invitation: invitation)
    subject
  end

  context "when invitation is not found" do
    let(:invitation_id) { 9999 }

    it "captures an error for missing invitation" do
      subject
      expect(Sentry).to have_received(:capture_message).with("Invitation not found", any_args)
    end
  end
end
