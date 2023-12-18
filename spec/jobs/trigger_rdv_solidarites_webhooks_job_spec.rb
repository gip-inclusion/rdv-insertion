describe TriggerRdvSolidaritesWebhooksJob do
  subject do
    described_class.new.perform(
      rdv_solidarites_webhook_endpoint_id, rdv_solidarites_organisation_id, agent.email
    )
  end

  let!(:rdv_solidarites_webhook_endpoint_id) { 17 }
  let!(:rdv_solidarites_organisation_id) { 1717 }
  let!(:agent) { create(:agent) }

  describe "#perform" do
    before do
      allow(RdvSolidaritesApi::UpdateWebhookEndpoint).to receive(:call)
        .with(
          rdv_solidarites_webhook_endpoint_id: rdv_solidarites_webhook_endpoint_id,
          rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
          trigger: true
        )
        .and_return(OpenStruct.new(success?: true))
    end

    it "sets the current agent" do
      subject
      expect(Current.agent).to eq(agent)
    end

    it "calls the update webhook service with the trigger option on" do
      expect(RdvSolidaritesApi::UpdateWebhookEndpoint).to receive(:call)
        .with(
          rdv_solidarites_webhook_endpoint_id: rdv_solidarites_webhook_endpoint_id,
          rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
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
