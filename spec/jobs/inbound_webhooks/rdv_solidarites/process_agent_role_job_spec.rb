describe InboundWebhooks::RdvSolidarites::ProcessAgentRoleJob do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "id" => rdv_solidarites_agent_role_id,
      "access_level" => "basic",
      "agent" => { id: rdv_solidarites_agent_id },
      "organisation" => { id: rdv_solidarites_organisation_id }
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_agent_role_id) { 17 }
  let!(:rdv_solidarites_organisation_id) { 222 }
  let!(:rdv_solidarites_agent_id) { 455 }

  let!(:organisation) do
    create(:organisation, rdv_solidarites_organisation_id:, id: 923, name: "Pôle Parcours")
  end
  let!(:agent) { create(:agent, rdv_solidarites_agent_id: rdv_solidarites_agent_id) }
  let!(:agent_role) { create(:agent_role, organisation: organisation, agent: agent) }
  let!(:meta) do
    {
      "model" => "AgentRole",
      "timestamp" => "2023-02-09 11:17:22 +0200",
      "event" => "updated"
    }.deep_symbolize_keys
  end

  describe "#perform" do
    before do
      allow_any_instance_of(described_class).to receive(:sleep)
    end

    it "upserts an agent_role record" do
      expect(UpsertRecordJob).to receive(:perform_async)
        .with(
          "AgentRole", data,
          { organisation_id: organisation.id, agent_id: agent.id,
            last_webhook_update_received_at: "2023-02-09 11:17:22 +0200" }
        )
      subject
    end

    context "for destroyed event" do
      let!(:meta) do
        {
          "model" => "AgentRole",
          "event" => "destroyed"
        }.deep_symbolize_keys
      end

      it "removes the agent from organisation" do
        expect { subject }.to change(AgentRole, :count).by(-1)
      end

      it "does not attach the agent to the organisation" do
        expect(UpsertRecordJob).not_to receive(:perform_async)
        subject
      end

      context "when the agent role record cannot be found through id" do
        before { data[:id] = "some-other-id" }

        it "still removes the agent from the organisation" do
          expect { subject }.to change(AgentRole, :count).by(-1)
        end
      end

      context "when the agent belongs to this org only" do
        it "destroys the agent" do
          expect { subject }.to change(Agent, :count).by(-1)
        end

        it "sends a message to mattermost" do
          expect(MattermostClient).to receive(:send_to_notif_channel)
            .with("agent removed from organisation Pôle Parcours (923) and deleted")
          subject
        end
      end

      context "when the agent belongs to multiple orgs" do
        before { create(:agent_role, organisation: create(:organisation), agent: agent) }

        it "does not destroy the agent" do
          expect { subject }.not_to change(Agent, :count)
        end

        it "still removes the agent from the organisation" do
          expect { subject }.to change(AgentRole, :count).by(-1)
        end
      end
    end

    context "when organisation cannot be found" do
      let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: 2131) }

      it "does not remove the agent from the org" do
        subject
        expect { subject }.not_to change(AgentRole, :count)
      end

      it "does not attach the agent to the organisation" do
        expect(UpsertRecordJob).not_to receive(:perform_async)
        subject
      end
    end

    context "when the agent cannot be found" do
      let!(:agent) { create(:agent, rdv_solidarites_agent_id: 4444) }
      let!(:meta) do
        {
          "model" => "AgentRole",
          "event" => "created",
          "timestamp" => "2022-05-30 14:44:22 +0200"
        }.deep_symbolize_keys
      end

      it "raises an error" do
        expect(UpsertRecordJob).to receive(:perform_async)
          .with(
            "Agent", data[:agent], { last_webhook_update_received_at: "2022-05-30 14:44:22 +0200" }
          )
        expect { subject }.to raise_error(
          StandardError,
          "Could not find agent 455. Launched upsert agent job and will retry"
        )
      end
    end
  end
end
