describe RdvSolidaritesWebhooks::TriggerEndpointJob do
  subject do
    described_class.new.perform(
      rdv_solidarites_webhook_endpoint_id, rdv_solidarites_organisation_id, rdv_solidarites_session_credentials
    )
  end

  let!(:rdv_solidarites_webhook_endpoint_id) { 17 }
  let!(:rdv_solidarites_organisation_id) { 1717 }
  let!(:rdv_solidarites_session_credentials) do
    { "client" => "someclient", "uid" => "janedoe@gouv.fr", "access_token" => "sometoken" }.symbolize_keys
  end
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::Base) }

  describe "#perform" do
    before do
      allow(RdvSolidaritesSessionFactory).to receive(:create_with)
        .with(**rdv_solidarites_session_credentials)
        .and_return(rdv_solidarites_session)
      allow(RdvSolidaritesApi::UpdateWebhookEndpoint).to receive(:call)
        .with(
          rdv_solidarites_webhook_endpoint_id: rdv_solidarites_webhook_endpoint_id,
          rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
          rdv_solidarites_session: rdv_solidarites_session,
          trigger: true
        )
        .and_return(OpenStruct.new(success?: true))
    end

    it "calls the update webhook service with the trigger option on" do
      expect(RdvSolidaritesApi::UpdateWebhookEndpoint).to receive(:call)
        .with(
          rdv_solidarites_webhook_endpoint_id: rdv_solidarites_webhook_endpoint_id,
          rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
          rdv_solidarites_session: rdv_solidarites_session,
          trigger: true
        )
      subject
    end

    context "when it fails to trigger the webhook" do
      before do
        allow(RdvSolidaritesApi::UpdateWebhookEndpoint).to receive(:call)
          .with(
            rdv_solidarites_webhook_endpoint_id: rdv_solidarites_webhook_endpoint_id,
            rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
            rdv_solidarites_session: rdv_solidarites_session,
            trigger: true
          )
          .and_return(OpenStruct.new(success?: false, errors: ["something went wrong"]))
      end

      it "raises an error" do
        expect { subject }.to raise_error(StandardError, "something went wrong")
      end
    end
  end
end
