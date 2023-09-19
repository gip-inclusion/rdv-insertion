describe RdvSolidaritesWebhooks::ProcessAgentsRdvJob do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "agent" => { "id" => rdv_solidarites_agent_id },
      "rdv" => { "id" => rdv_solidarites_rdv_id }
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_agent_id) { 232 }
  let!(:rdv_solidarites_rdv_id) { 636 }

  let!(:agent) { create(:agent, rdv_solidarites_agent_id:) }
  let!(:rdv) { create(:rdv, rdv_solidarites_rdv_id:) }
  let!(:meta) do
    {
      "model" => "AgentsRdv",
      "event" => "created"
    }.deep_symbolize_keys
  end

  describe "#perform" do
    context "for created event" do
      let!(:meta) do
        {
          "model" => "AgentsRdv",
          "event" => "created"
        }.deep_symbolize_keys
      end

      it "adds the agent to the rdv" do
        subject
        expect(rdv.reload.agents).to include(agent)
      end

      context "when the rdv does not exist in db" do
        let!(:rdv) { create(:rdv, rdv_solidarites_rdv_id: "some-other-id") }

        it "does not add a rdv to the agent" do
          subject
          expect(agent.reload.rdvs).to eq([])
        end
      end

      context "when the agent does not exist in db" do
        let!(:agent) { create(:agent, rdv_solidarites_agent_id: "some-other-id") }

        it "does not add the agent to the rdv" do
          subject
          expect(rdv.reload.agents).to eq([])
        end
      end
    end

    context "for a destroyed event" do
      let!(:rdv) { create(:rdv, rdv_solidarites_rdv_id:, agents: [agent]) }
      let!(:meta) do
        {
          "model" => "AgentsRdv",
          "event" => "destroyed"
        }.deep_symbolize_keys
      end

      it "removes the agent from the rdv" do
        subject
        expect(rdv.reload.agents).not_to include(agent)
      end
    end
  end
end
