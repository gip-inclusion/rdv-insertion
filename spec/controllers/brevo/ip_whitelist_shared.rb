RSpec.shared_context "with ip whitelist", shared_context: :metadata do
  let(:remote_ip) { "1.179.112.1" }

  before do
    stub_brevo_webhook_ip(remote_ip)
  end

  private

  def stub_brevo_webhook_ip(remote_ip)
    [
      Brevo::MailWebhooksController,
      Brevo::SmsWebhooksController
    ].each do |controller|
      allow_any_instance_of(controller).to receive(:request).and_wrap_original do |original_request|
        original_request.call.tap do |request|
          allow(request).to receive(:remote_ip).and_return(remote_ip)
        end
      end
    end
  end
end

RSpec.shared_examples "returns 403 for non-whitelisted IP" do |ip|
  let(:remote_ip) { ip }

  context "when called with non-matching IP" do
    it "returns 403" do
      expect(Sentry).to(
        receive(:capture_message).with("Brevo Webhook received with following non whitelisted IP #{remote_ip}")
      )
      post :create, params: {}, as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end

  context "when whitelisting is disabled" do
    before do
      ENV["DISABLE_BREVO_IP_WHITELIST"] = "true"
    end

    it "skips whitelisting" do
      expect(Sentry).not_to(
        receive(:capture_message).with("Brevo Webhook received with following non whitelisted IP #{remote_ip}")
      )
      post :create, params: {}, as: :json
      expect(response).not_to have_http_status(:forbidden)
    end
  end
end
