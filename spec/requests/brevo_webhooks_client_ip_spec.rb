RSpec.describe "Client IP of Brevo webhooks" do
  subject { post "/brevo/sms_webhooks/invitation_1", params: webhook_params, headers:, as: :json }

  let(:webhook_params) { { to: "0601010101", msg_status: "delivered", date: "2023-06-07T12:34:56Z" } }
  let(:brevo_ip) { "1.179.112.1" }
  let(:client_ip) { "203.0.113.50" }

  before do
    allow(InboundWebhooks::Brevo::ProcessSmsDeliveryStatusJob).to receive(:perform_later)
    allow(Sentry).to receive(:capture_message)
  end

  context "when the proxy reports a Brevo IP in X-Forwarded-For" do
    let(:headers) { { "X-Forwarded-For" => brevo_ip } }

    it "accepts the webhook" do
      subject
      expect(response).to be_successful
      expect(InboundWebhooks::Brevo::ProcessSmsDeliveryStatusJob).to have_received(:perform_later)
    end
  end

  context "when the client sends a Brevo IP in the Forwarded header" do
    let(:headers) { { "Forwarded" => "for=#{brevo_ip}", "X-Forwarded-For" => client_ip } }

    it "refuses the webhook" do
      subject
      expect(response).to have_http_status(:forbidden)
      expect(InboundWebhooks::Brevo::ProcessSmsDeliveryStatusJob).not_to have_received(:perform_later)
    end

    it "reports the IP added by the proxy" do
      subject
      expect(Sentry).to have_received(:capture_message).with(
        "Brevo Webhook received with following non whitelisted IP", extra: { ip: client_ip }
      )
    end
  end

  context "when the client sends a Brevo IP on the left of X-Forwarded-For" do
    let(:headers) { { "X-Forwarded-For" => "#{brevo_ip}, #{client_ip}" } }

    it "refuses the webhook" do
      subject
      expect(response).to have_http_status(:forbidden)
      expect(InboundWebhooks::Brevo::ProcessSmsDeliveryStatusJob).not_to have_received(:perform_later)
    end
  end
end
