describe RdvSolidaritesApi::CreateWebhookEndpoint, type: :service do
  subject do
    described_class.call(
      rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  let!(:rdv_solidarites_organisation_id) { 1717 }
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::Base) }
  let!(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }

  describe "#call" do
    before do
      allow(rdv_solidarites_session).to receive(:rdv_solidarites_client)
        .and_return(rdv_solidarites_client)
      allow(rdv_solidarites_client).to receive(:create_webhook_endpoint)
        .with(rdv_solidarites_organisation_id, WebhookEndpoint::ALL_SUBSCRIPTIONS)
        .and_return(OpenStruct.new(success?: true))
    end

    it "tries to create a webhook endpoint in rdv solidarites" do
      expect(rdv_solidarites_client).to receive(:create_webhook_endpoint)
        .with(rdv_solidarites_organisation_id, WebhookEndpoint::ALL_SUBSCRIPTIONS)
      subject
    end

    it "is a success" do
      is_a_success
    end

    context "when a subscriptions list is passed" do
      subject do
        described_class.call(
          rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
          rdv_solidarites_session: rdv_solidarites_session,
          subscriptions: subscriptions
        )
      end

      before do
        allow(rdv_solidarites_client).to receive(:create_webhook_endpoint)
          .with(rdv_solidarites_organisation_id, subscriptions)
          .and_return(OpenStruct.new(success?: true))
      end

      let!(:subscriptions) { %w[user rdv organisation] }

      it "calls the client with the right arguments" do
        expect(rdv_solidarites_client).to receive(:create_webhook_endpoint)
          .with(rdv_solidarites_organisation_id, subscriptions)
        subject
      end
    end

    context "when the response is unsuccessful" do
      let(:response_body) { { error_messages: ["some error"] }.to_json }

      before do
        allow(rdv_solidarites_client).to receive(:create_webhook_endpoint)
          .with(rdv_solidarites_organisation_id, WebhookEndpoint::ALL_SUBSCRIPTIONS)
          .and_return(OpenStruct.new(body: response_body, success?: false))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["Erreur RDV-Solidarités: some error"])
      end
    end
  end
end
