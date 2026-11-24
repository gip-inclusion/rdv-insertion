describe InboundWebhooks::RdvSolidarites::ProcessAgentJob do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "id" => rdv_solidarites_agent_id,
      "email" => "linus@linux.com",
      "first_name" => "Linus",
      "last_name" => "Torvalds"
    }.deep_symbolize_keys
  end

  let!(:meta) do
    {
      "model" => "Agent",
      "event" => "updated",
      "timestamp" => "2022-05-30 14:44:22 +0200"
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_agent_id) { 44 }
  let!(:agent) { create(:agent, rdv_solidarites_agent_id: rdv_solidarites_agent_id, email: "linus@torvalds.com") }

  describe "#perform" do
    it "updates the agent" do
      subject
      expect(agent.reload).to have_attributes(
        email: "linus@linux.com",
        first_name: "Linus",
        last_name: "Torvalds",
        last_webhook_update_received_at: "2022-05-30 14:44:22 +0200".to_datetime
      )
    end

    context "when the agent does not exist" do
      let!(:agent) { create(:agent, rdv_solidarites_agent_id: 45) }

      let!(:meta) do
        {
          "model" => "Agent",
          "event" => "created",
          "timestamp" => "2022-05-30 14:44:22 +0200"
        }.deep_symbolize_keys
      end

      it "does not create the agent" do
        expect { subject }.not_to change(Agent, :count)
      end
    end

    context "when it is a destroyed event" do
      let!(:meta) do
        {
          "model" => "Agent",
          "event" => "destroyed",
          "timestamp" => "2022-05-30 14:44:22 +0200"
        }.deep_symbolize_keys
      end

      it "deletes the agent" do
        expect { subject }.to change(Agent, :count).by(-1)
      end
    end

    context "when the email is blank" do
      let!(:data) do
        {
          "id" => rdv_solidarites_agent_id,
          "email" => ""
        }.deep_symbolize_keys
      end

      it "does not update the agent" do
        subject
        expect(agent.reload.email).to eq("linus@torvalds.com")
      end
    end
  end
end
