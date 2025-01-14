require_relative "ip_whitelist_shared"

describe Brevo::SmsWebhooksController do
  include_context "with ip whitelist"

  describe "#create" do
    before do
      allow(InboundWebhooks::Brevo::ProcessSmsDeliveryStatusJob).to receive(:perform_later)
    end

    let(:valid_sms_params) do
      { to: "1234567890", msg_status: "delivered", date: "2023-06-07T12:34:56Z", record_identifier: "invitation_1" }
    end

    context "when called with non-matching IP" do
      include_examples "returns 403 for non-whitelisted IP", "18.12.12.12"
    end

    it "enqueues the job for processing SMS delivery status" do
      expect(InboundWebhooks::Brevo::ProcessSmsDeliveryStatusJob).to receive(:perform_later)
        .with({ to: "1234567890", msg_status: "delivered", date: "2023-06-07T12:34:56Z" }, "invitation_1")
      post :create, params: valid_sms_params, as: :json
      expect(response).to be_successful
    end
  end
end
