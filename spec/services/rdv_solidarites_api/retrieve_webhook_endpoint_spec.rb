describe RdvSolidaritesApi::RetrieveWebhookEndpoint, type: :service do
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
    let!(:webhook_endpoints) do
      [{
        "id" => 17,
        "organisation_id" => 1717,
        "target_url" => "http://test-departement/api/v1/webhook"
      }]
    end

    before do
      allow(rdv_solidarites_session).to receive(:rdv_solidarites_client)
        .and_return(rdv_solidarites_client)
      allow(rdv_solidarites_client).to receive(:get_webhook_endpoint)
        .with(rdv_solidarites_organisation_id)
        .and_return(OpenStruct.new(success?: true, body: { "webhook_endpoints" => webhook_endpoints }.to_json))
    end

    context "when it succeeds" do
      it("is a success") { is_a_success }

      it "retrieves the motifs" do
        expect(rdv_solidarites_client).to receive(:get_webhook_endpoint)
        subject
      end

      it "returns the webhook_endpoint" do
        expect(subject.webhook_endpoint.id).to eq(17)
      end
    end

    context "when it fails" do
      before do
        allow(rdv_solidarites_client).to receive(:get_webhook_endpoint)
          .and_return(OpenStruct.new(success?: false, body: { error_messages: ["some error"] }.to_json))
      end

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Erreur RDV-Solidarités: some error"])
      end
    end
  end
end
