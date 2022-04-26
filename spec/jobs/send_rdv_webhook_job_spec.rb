describe SendRdvWebhookJob, type: :job do
  subject do
    described_class.new.perform(webhook_endpoint_id, rdv_payload, [93], meta)
  end

  let!(:webhook_endpoint_id) { 2222 }
  let!(:webhook_url) { "http://some-test-url.com" }
  let!(:webhook_secret) { "some-secret" }
  let!(:webhook_endpoint) do
    create(:webhook_endpoint, id: webhook_endpoint_id, url: webhook_url, secret: webhook_secret)
  end

  let!(:applicant) { create(:applicant, applicant_payload) }

  let!(:applicant_payload) do
    {
      id: 93,
      affiliation_number: "1231123",
      role: "demandeur",
      department_internal_id: "4444",
      first_name: "john",
      last_name: "doe",
      address: "29 rue de la paix",
      phone_number: "0743399339",
      email: "john@doe.com",
      title: "monsieur",
      birth_date: "1958-11-21",
      rights_opening_date: "2020-11-21"
    }
  end

  let!(:rdv_payload) do
    {
      id: 12,
      users: [
        { id: 1231, first_name: "john", last_name: "doe" }
      ],
      lieu: { id: "1122112", address: "20 avenue de ségur" }
    }
  end

  let!(:meta) { { event: "created" } }

  describe "#perform" do
    let!(:now) { Date.new(2022, 7, 22) }
    let!(:exp) { (now + 10.minutes).to_i }
    let!(:jwt_payload) do
      { id: 93, first_name: "john", last_name: "doe", exp: exp }
    end
    let!(:jwt_token) { "stubbed-token" }
    let!(:webhook_payload) do
      {
        id: 12,
        lieu: { id: "1122112", address: "20 avenue de ségur" },
        applicants: [applicant_payload],
        event: "created"
      }.to_json
    end
    let!(:request_headers) do
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "Authorization" => "Bearer stubbed-token"
      }
    end

    before do
      travel_to(now)

      allow(JWT).to receive(:encode)
        .with(jwt_payload, webhook_secret, "HS256")
        .and_return(jwt_token)
      allow(Faraday).to receive(:post)
        .with(webhook_url, webhook_payload, request_headers)
        .and_return(OpenStruct.new(success?: true))
    end

    it "sends the webhook" do
      expect(Faraday).to receive(:post)
        .with(webhook_url, webhook_payload, request_headers)
      subject
    end

    context "when the request fails" do
      before do
        allow(Faraday).to receive(:post)
          .with(webhook_url, webhook_payload, request_headers)
          .and_return(OpenStruct.new(success?: false, status: "422", body: "something happened"))
      end

      let!(:error_message) do
        "Could not send webhook to url http://some-test-url.com\n" \
          "rdv solidarites rdv id: 12\n" \
          "response status: 422\n" \
          "response body: something happened"
      end

      it "raises an error" do
        expect { subject }.to raise_error(OutgoingWebhookError, error_message)
      end
    end
  end
end
