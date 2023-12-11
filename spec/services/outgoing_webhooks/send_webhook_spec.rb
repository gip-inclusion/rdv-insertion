describe OutgoingWebhooks::SendWebhook, type: :service do
  subject do
    described_class.call(webhook_endpoint:, webhook_payload:, webhook_signature:)
  end

  let!(:webhook_payload) do
    { data:, meta: }
  end

  let!(:url) { "https://www.departement.fr/rdvs" }

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
      timestamp: timestamp
    }
  end
  let!(:timestamp) { Time.zone.parse("31/01/2023 22:22:52") }

  let!(:webhook_endpoint) { create(:webhook_endpoint, url:) }
  let!(:webhook_signature) do
    { "X-RDVI-SIGNATURE" => "some-signature" }
  end

  let!(:request_headers) do
    {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }.merge(webhook_signature)
  end

  before do
    allow(Faraday).to receive(:post)
      .with(url, webhook_payload.to_json, request_headers)
      .and_return(OpenStruct.new(success?: true))
  end

  it("is a success") { is_a_success }

  it "sends the webhook" do
    expect(Faraday).to receive(:post)
      .with(url, webhook_payload.to_json, request_headers)
    subject
  end

  it "creates a receipt" do
    subject
    webhook_receipt = WebhookReceipt.last
    expect(webhook_receipt.timestamp).to eq(timestamp)
    expect(webhook_receipt.webhook_endpoint_id).to eq(webhook_endpoint.id)
    expect(webhook_receipt.resource_id).to eq(294)
    expect(webhook_receipt.resource_model).to eq("Rdv")
  end

  context "when the request fails" do
    let!(:response_body) do
      { "errors" => ["something happened"] }
    end

    before do
      allow(Faraday).to receive(:post)
        .with(url, webhook_payload.to_json, request_headers)
        .and_return(OpenStruct.new(success?: false, status: 422, body: response_body.to_json))
    end

    it("is a failure") { is_a_failure }

    it "has an error message" do
      expect(subject.errors).to eq(
        [
          "Could not send webhook to url https://www.departement.fr/rdvs\n" \
          "resource model: Rdv\n" \
          "resource id: 294\n" \
          "response status: 422\n" \
          "response body: {\"errors\":[\"something happened\"]}"
        ]
      )
    end
  end

  context "when there is a recipe already for this resource" do
    let!(:receipt_timestamp) { Time.zone.parse("31/01/2023 22:22:53") }
    let!(:webhook_receipt) do
      create(
        :webhook_receipt,
        timestamp: receipt_timestamp, webhook_endpoint:, resource_model: "Rdv",
        resource_id: 294
      )
    end

    it("is a success") { is_a_success }

    it "does not send a webhook" do
      expect(Faraday).not_to receive(:post)
      subject
    end

    context "when the receipt timestamp is prior than the webhook timestamp" do
      let!(:receipt_timestamp) { Time.zone.parse("31/01/2023 22:22:51") }

      it("is a success") { is_a_success }

      it "sends the webhook" do
        expect(Faraday).to receive(:post)
          .with(url, webhook_payload.to_json, request_headers)
        subject
      end

      it "creates a new receipt" do
        subject
        expect(WebhookReceipt.count).to eq(2)
        expect(WebhookReceipt.last.timestamp).to eq(timestamp)
      end
    end

    context "when there is no receipt is for this model" do
      before { webhook_receipt.update!(resource_model: "Invitation") }

      it("is a success") { is_a_success }

      it "sends the webhook" do
        expect(Faraday).to receive(:post)
          .with(url, webhook_payload.to_json, request_headers)
        subject
      end

      it "creates a new receipt" do
        subject
        expect(WebhookReceipt.count).to eq(2)
        expect(WebhookReceipt.last.timestamp).to eq(timestamp)
      end
    end

    context "when there is no receipt for this resource" do
      before { webhook_receipt.update!(resource_id: 51) }

      it("is a success") { is_a_success }

      it "sends the webhook" do
        expect(Faraday).to receive(:post)
          .with(url, webhook_payload.to_json, request_headers)
        subject
      end

      it "creates a new receipt" do
        subject
        expect(WebhookReceipt.count).to eq(2)
        expect(WebhookReceipt.last.timestamp).to eq(timestamp)
      end
    end
  end
end
