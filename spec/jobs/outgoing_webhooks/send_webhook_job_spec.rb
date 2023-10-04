describe OutgoingWebhooks::SendWebhookJob do
  subject do
    described_class.new.perform(webhook_endpoint_id, webhook_payload)
  end

  let!(:webhook_endpoint) do
    create(:webhook_endpoint, id: webhook_endpoint_id, signature_type:, secret: "secret")
  end

  let!(:signature_type) { "jwt" }

  let!(:webhook_endpoint_id) { 22 }

  let!(:webhook_payload) do
    { data:, meta: }
  end

  let!(:data) do
    {
      id: 294,
      address: "20 avenue de Ségur 75007 Paris",
      starts_at: 2.days.from_now
    }
  end

  let!(:meta) do
    {
      model: "Rdv",
      timestamp: now
    }
  end
  let!(:now) { Time.zone.parse("31/01/2023") }

  before do
    travel_to(now)
    allow(OutgoingWebhooks::SendWebhook).to receive(:call)
      .and_return(OpenStruct.new(success?: true))
  end

  it "sends calls the webhook service with the correct signature" do
    jwt = JWT.encode(data, "secret", "HS256", { typ: "JWT", exp: 10.minutes.from_now.to_i })
    jwt_signature = { "Authorization" => "Bearer #{jwt}" }
    expect(OutgoingWebhooks::SendWebhook).to receive(:call)
      .with(
        webhook_endpoint:, webhook_payload:, webhook_signature: jwt_signature
      )
    subject
  end

  context "when jwt signature cannot be computed" do
    before { meta[:model] = "Invitation" }

    it "raises an error" do
      expect { subject }.to raise_error(OutgoingWebhookError, "JWT signature impossible for Invitation")
    end
  end

  context "when the signature is hmac" do
    let!(:signature_type) { "hmac" }
    let!(:webhook_signature) do
      { "X-RDVI-SIGNATURE" => OpenSSL::HMAC.hexdigest("SHA256", "secret", webhook_payload.to_json) }
    end

    it "sends calls the webhook service with the correct signature" do
      expect(OutgoingWebhooks::SendWebhook).to receive(:call)
        .with(webhook_endpoint:, webhook_payload:, webhook_signature:)
      subject
    end
  end
end
