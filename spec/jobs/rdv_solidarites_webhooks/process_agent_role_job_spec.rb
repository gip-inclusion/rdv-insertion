describe RdvSolidaritesWebhooks::ProcessAgentRoleJob do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "agent" => { id: rdv_solidarites_agent_id },
      "organisation" => { id: rdv_solidarites_organisation_id }
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_organisation_id) { 222 }
  let!(:rdv_solidarites_agent_id) { 455 }

  let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id) }
  let!(:agent) { create(:agent, rdv_solidarites_agent_id: rdv_solidarites_agent_id) }

  describe "#perform" do
    before { allow_any_instance_of(described_class).to receive(:sleep) }

    context "for created event" do
      let!(:meta) do
        {
          "model" => "AgentRole",
          "event" => "created"
        }.deep_symbolize_keys
      end

      it "attach the agent to the organisation" do
        subject
        expect(agent.reload.organisation_ids).to include(organisation.id)
      end
    end

    context "for destroyed event" do
      before { agent.organisations << organisation }

      let!(:meta) do
        {
          "model" => "AgentRole",
          "event" => "destroyed"
        }.deep_symbolize_keys
      end

      it "removes the agent from the organisation" do
        subject
        expect(agent.reload.organisation_ids).not_to include(organisation.id)
      end

      context "when organisation cannot be found" do
        let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: 2131) }

        it "does not remove the agent from the org" do
          subject
          expect(agent.reload.organisation_ids).to include(organisation.id)
        end
      end
    end

    context "when the agent cannot be found" do
      let!(:agent) { create(:agent, rdv_solidarites_agent_id: 4444) }
      let!(:meta) do
        {
          "model" => "AgentRole",
          "event" => "created"
        }.deep_symbolize_keys
      end

      it "raises an error" do
        expect { subject }.to raise_error(StandardError, "Could not find agent: #{data[:agent]}")
      end
    end
  end
end
