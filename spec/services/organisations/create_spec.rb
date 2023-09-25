describe Organisations::Create, type: :service do
  subject do
    described_class.call(
      rdv_solidarites_session: rdv_solidarites_session,
      current_agent: agent,
      organisation: organisation
    )
  end

  let!(:rdv_solidarites_organisation_id) { 1717 }
  let!(:webhook_endpoint_id) { 171_717 }
  let!(:department) { create(:department) }
  let!(:organisation) do
    build(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
                         name: nil, phone_number: nil, department: department)
  end
  let!(:organisation_from_rdvs) do
    RdvSolidarites::Organisation.new(name: "Nouvelle org", phone_number: "0102030405")
  end
  let!(:agent) { create(:agent, email: "alain.sertion@departement.fr") }
  let!(:organisation_count_before) { Organisation.count }
  let!(:agent_roles_count_before) { AgentRole.count }

  let(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::Base) }
  let!(:rdv_solidarites_session_credentials) do
    { "client" => "someclient", "uid" => "janedoe@gouv.fr", "access_token" => "sometoken" }.symbolize_keys
  end

  describe "#call" do
    before do
      allow(RdvSolidaritesApi::RetrieveOrganisation).to receive(:call)
        .and_return(OpenStruct.new(success?: true, organisation: organisation_from_rdvs))
      allow(RdvSolidaritesApi::CreateWebhookEndpoint).to receive(:call)
        .and_return(OpenStruct.new(success?: true, webhook_endpoint_id: webhook_endpoint_id))
      allow(RdvSolidaritesApi::UpdateWebhookEndpoint).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
      allow(RdvSolidaritesApi::RetrieveWebhookEndpoint).to receive(:call)
        .and_return(OpenStruct.new(success?: true, webhook_endpoint: nil))
      allow(RdvSolidaritesApi::UpdateOrganisation).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
      allow(rdv_solidarites_session).to receive(:to_h)
        .and_return(rdv_solidarites_session_credentials)
      allow(TriggerRdvSolidaritesWebhooksJob).to receive(:perform_async)
        .with(webhook_endpoint_id, rdv_solidarites_organisation_id, rdv_solidarites_session_credentials)
    end

    it "is a success" do
      is_a_success
    end

    it "tries to retrieve an organisation from rdvs" do
      expect(RdvSolidaritesApi::RetrieveOrganisation).to receive(:call)
      subject
    end

    it "assigns attributes to the organisation" do
      subject
      expect(organisation.reload.name).to eq("Nouvelle org")
      expect(organisation.reload.phone_number).to eq("0102030405")
    end

    it "saves the organisation in db" do
      subject
      expect(Organisation.count).to eq(organisation_count_before + 1)
    end

    it "creates a agent role for the current agent" do
      subject
      expect(AgentRole.count).to eq(agent_roles_count_before + 1)
      expect(AgentRole.last.agent_id).to eq(agent.id)
      expect(AgentRole.last.organisation_id).to eq(organisation.id)
    end

    it "calls the retrieve webhook endpoint service" do
      expect(RdvSolidaritesApi::RetrieveWebhookEndpoint).to receive(:call)
      subject
    end

    it "calls the create webhook endpoint service" do
      expect(RdvSolidaritesApi::CreateWebhookEndpoint).to receive(:call)
      subject
    end

    it "calls the update webhook endpoint service (for verticale attribute)" do
      expect(RdvSolidaritesApi::UpdateOrganisation).to receive(:call).with(
        hash_including(
          {
            organisation_attributes: hash_including(
              {
                "verticale" => "rdv_insertion"
              }
            )
          }
        )
      )
      subject
    end

    it "calls the TriggerRdvSolidaritesWebhooksJob" do
      expect(TriggerRdvSolidaritesWebhooksJob).to receive(:perform_async)
        .with(webhook_endpoint_id, rdv_solidarites_organisation_id, rdv_solidarites_session_credentials)
      subject
    end

    context "when the organisation has no rdv solidarites id" do
      let!(:organisation) do
        build(:organisation, rdv_solidarites_organisation_id: nil, name: nil, phone_number: nil, department: department)
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["L'ID de l'organisation RDV-Solidarités n'a pas été renseigné correctement"])
      end

      it "does not call the TriggerRdvSolidaritesWebhooksJob" do
        expect(TriggerRdvSolidaritesWebhooksJob).not_to receive(:perform_async)
      end
    end

    context "when the organisation cannot be saved in db" do
      before do
        allow(organisation).to receive(:save)
          .and_return(false)
        allow(organisation).to receive_message_chain(:errors, :full_messages, :to_sentence)
          .and_return("some error")
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["some error"])
      end

      it "does not call the TriggerRdvSolidaritesWebhooksJob" do
        expect(TriggerRdvSolidaritesWebhooksJob).not_to receive(:perform_async)
      end
    end

    context "when the rdv solidarites organisation update fails" do
      before do
        allow(RdvSolidaritesApi::RetrieveOrganisation).to receive(:call)
          .and_return(OpenStruct.new(errors: ["some error"], success?: false))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["some error"])
      end

      it "does not call the TriggerRdvSolidaritesWebhooksJob" do
        expect(TriggerRdvSolidaritesWebhooksJob).not_to receive(:perform_async)
      end
    end

    context "when the rdv solidarites webhook endpoint create fails" do
      before do
        allow(RdvSolidaritesApi::RetrieveWebhookEndpoint).to receive(:call)
          .and_return(OpenStruct.new(success?: true, webhook_endpoint: nil))
        allow(RdvSolidaritesApi::CreateWebhookEndpoint).to receive(:call)
          .and_return(OpenStruct.new(errors: ["some error"], success?: false))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["some error"])
      end

      it "does not call the TriggerRdvSolidaritesWebhooksJob" do
        expect(TriggerRdvSolidaritesWebhooksJob).not_to receive(:perform_async)
      end
    end

    context "when the rdv solidarites webhook endpoint already exists" do
      before do
        allow(RdvSolidaritesApi::RetrieveWebhookEndpoint).to receive(:call)
          .and_return(
            OpenStruct.new(
              success?: true,
              webhook_endpoint: RdvSolidarites::WebhookEndpoint.new(organisation_id: rdv_solidarites_organisation_id,
                                                                    target_url: "http://test-departement/api/v1/webhook",
                                                                    secret: "secret",
                                                                    subscriptions: %w[rdv absence plage_ouverture])
            )
          )
      end

      it "calls the update webhook endpoint service" do
        expect(RdvSolidaritesApi::UpdateWebhookEndpoint).to receive(:call)
        subject
      end

      context "when the rdv solidarites webhook endpoint update fails" do
        before do
          allow(RdvSolidaritesApi::UpdateWebhookEndpoint).to receive(:call)
            .and_return(OpenStruct.new(errors: ["some error"], success?: false))
        end

        it "is a failure" do
          is_a_failure
        end

        it "stores the error" do
          expect(subject.errors).to eq(["some error"])
        end

        it "does not call the TriggerRdvSolidaritesWebhooksJob" do
          expect(TriggerRdvSolidaritesWebhooksJob).not_to receive(:perform_async)
        end
      end
    end
  end
end
