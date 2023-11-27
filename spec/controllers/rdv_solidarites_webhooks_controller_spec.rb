describe RdvSolidaritesWebhooksController do
  before do
    allow(InboundWebhooks::RdvSolidarites::ProcessRdvJob).to receive(:perform_async)
    allow(InboundWebhooks::RdvSolidarites::ProcessUserJob).to receive(:perform_async)
    allow(InboundWebhooks::RdvSolidarites::ProcessUserProfileJob).to receive(:perform_async)
    ENV["RDV_SOLIDARITES_SECRET"] = "i am secret"
  end

  let!(:meta) { { event: "created", model: "Rdv" } }
  let!(:data) { { users: [{ id: 123 }], organisation: { id: 15 } } }
  let!(:webhook_params) do
    {
      meta: meta,
      data: data
    }
  end

  it "enqueues the job" do
    request.headers["X-Lapin-Signature"] = OpenSSL::HMAC.hexdigest(
      "SHA256", "i am secret", webhook_params.to_json
    )
    expect(InboundWebhooks::RdvSolidarites::ProcessRdvJob).to receive(:perform_async)
      .with(data, meta)
    post :create, params: webhook_params, as: :json
    expect(response).to be_successful
  end

  context "for a user" do
    let!(:meta) { { event: "created", model: "User" } }

    it "enqueues the user job" do
      request.headers["X-Lapin-Signature"] = OpenSSL::HMAC.hexdigest(
        "SHA256", "i am secret", webhook_params.to_json
      )
      expect(InboundWebhooks::RdvSolidarites::ProcessUserJob).to receive(:perform_async)
        .with(data, meta)
      post :create, params: webhook_params, as: :json
      expect(response).to be_successful
    end
  end

  context "for a user profile" do
    let!(:meta) { { event: "created", model: "UserProfile" } }

    it "enqueues the user profile job" do
      request.headers["X-Lapin-Signature"] = OpenSSL::HMAC.hexdigest(
        "SHA256", "i am secret", webhook_params.to_json
      )
      expect(InboundWebhooks::RdvSolidarites::ProcessUserProfileJob).to receive(:perform_async)
        .with(data, meta)
      post :create, params: webhook_params, as: :json
      expect(response).to be_successful
    end
  end

  context "for an organisation" do
    let!(:meta) { { event: "updated", model: "Organisation" } }

    it "enqueues the organisation job" do
      request.headers["X-Lapin-Signature"] = OpenSSL::HMAC.hexdigest(
        "SHA256", "i am secret", webhook_params.to_json
      )
      expect(InboundWebhooks::RdvSolidarites::ProcessOrganisationJob).to receive(:perform_async)
        .with(data, meta)
      post :create, params: webhook_params, as: :json
      expect(response).to be_successful
    end
  end

  context "when the webhook is not verified" do
    it "is a bad request" do
      request.headers["X-Lapin-Signature"] = "wrong signature"
      expect(InboundWebhooks::RdvSolidarites::ProcessRdvJob).not_to receive(:perform_async)
      post :create, params: webhook_params
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq("webhook auth error")
    end
  end

  context "when the model is not handled" do
    let!(:meta) { { event: "created", model: "Absence" } }

    it "does not enqueue the job" do
      request.headers["X-Lapin-Signature"] = OpenSSL::HMAC.hexdigest(
        "SHA256", "i am secret", webhook_params.to_json
      )
      expect(InboundWebhooks::RdvSolidarites::ProcessRdvJob).not_to receive(:perform_async)
        .with(meta, data)
      post :create, params: webhook_params, as: :json
      expect(response).to be_successful
      expect(response.body).to eq("webhook event not handled")
    end
  end
end
