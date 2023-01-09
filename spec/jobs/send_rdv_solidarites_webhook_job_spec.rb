describe SendRdvSolidaritesWebhookJob do
  subject do
    described_class.new.perform(webhook_endpoint_id, webhook_payload)
  end

  let!(:webhook_endpoint_id) { 2222 }
  let!(:webhook_url) { "http://some-test-url.com" }
  let!(:webhook_secret) { "some-secret" }
  let!(:webhook_endpoint) do
    create(:webhook_endpoint, id: webhook_endpoint_id, url: webhook_url, secret: webhook_secret)
  end
  let!(:rdv_solidarites_rdv_id) { 1515 }
  let!(:webhook_payload) do
    {
      data: {
        id: rdv_solidarites_rdv_id,
        address: "20 avenue de Ségur 75015 Paris",
        starts_at: "20-12-2022",
        lieu: { id: "1122112", address: "20 avenue de ségur" },
        users: [{ id: 5, department_internal_id: "6" }]
      },
      meta: { event: "created", timestamp: "2020-05-02 15:02" }
    }
  end

  describe "#perform" do
    let!(:now) { Time.zone.parse("2020-05-02 15:05") }
    let!(:exp) { (now + 10.minutes).to_i }
    let!(:jwt_payload) do
      { id: rdv_solidarites_rdv_id, address: "20 avenue de Ségur 75015 Paris", starts_at: "20-12-2022" }
    end
    let!(:jwt_headers) { { typ: "JWT", exp: exp } }
    let!(:jwt_token) { "stubbed-token" }
    let!(:request_headers) do
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "Authorization" => "Bearer stubbed-token"
      }
    end
    let!(:webhook_receipt) do
      build(:webhook_receipt, webhook_endpoint: webhook_endpoint, rdv_solidarites_rdv_id: rdv_solidarites_rdv_id)
    end

    before do
      travel_to(now)

      allow(JWT).to receive(:encode)
        .with(jwt_payload, webhook_secret, "HS256", jwt_headers)
        .and_return(jwt_token)
      allow(Faraday).to receive(:post)
        .with(webhook_url, webhook_payload.to_json, request_headers)
        .and_return(OpenStruct.new(success?: true))
      allow(WebhookReceipt).to receive(:find_or_initialize_by)
        .and_return(webhook_receipt)
    end

    it "sends the webhook" do
      expect(Faraday).to receive(:post)
        .with(webhook_url, webhook_payload.to_json, request_headers)
      subject
    end

    it "adds timestamp to the receipt" do
      expect(webhook_receipt).to receive(:update!)
        .with(rdvs_webhook_timestamp: "2020-05-02 15:02".to_datetime, sent_at: now)
      subject
    end

    context "when the request fails" do
      before do
        allow(Faraday).to receive(:post)
          .with(webhook_url, webhook_payload.to_json, request_headers)
          .and_return(OpenStruct.new(success?: false, status: "422", body: "something happened"))
      end

      let!(:error_message) do
        "Could not send webhook to url http://some-test-url.com\n" \
          "rdv solidarites rdv id: 1515\n" \
          "response status: 422\n" \
          "response body: something happened"
      end

      it "raises an error" do
        expect { subject }.to raise_error(OutgoingWebhookError, error_message)
      end
    end

    context "when it is an old webhook" do
      let!(:webhook_receipt) do
        create(:webhook_receipt,
               webhook_endpoint: webhook_endpoint, rdvs_webhook_timestamp: "2020-05-02 15:03".to_datetime,
               rdv_solidarites_rdv_id: rdv_solidarites_rdv_id, sent_at: now)
      end

      it "does not send a webhook" do
        expect(Faraday).not_to receive(:post)
        subject
      end

      it "does not update the receipt" do
        expect(webhook_receipt).not_to receive(:update!)
        subject
      end
    end
  end
end
