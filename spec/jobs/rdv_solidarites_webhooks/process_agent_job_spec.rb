describe RdvSolidaritesWebhooks::ProcessAgentJob, type: :job do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "id" => rdv_solidarites_agent_id,
      "email" => "linus@linux.com"
    }.deep_symbolize_keys
  end

  let!(:meta) do
    {
      "model" => "Agent",
      "event" => "created",
      "timestamp" => "2022-05-30 14:44:22 +0200"
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_agent_id) { 44 }

  describe "#perform" do
    it "upserts the agent" do
      expect(UpsertRecordJob).to receive(:perform_async)
        .with("Agent", data, { last_webhook_update_received_at: "2022-05-30 14:44:22 +0200" })
      subject
    end

    context "when it is a destroyed event" do
      let!(:agent) { create(:agent, rdv_solidarites_agent_id: rdv_solidarites_agent_id) }

      let!(:meta) do
        {
          "model" => "Agent",
          "event" => "destroyed",
          "timestamp" => "2022-05-30 14:44:22 +0200"
        }.deep_symbolize_keys
      end

      it "deletes the agent" do
        expect(UpsertRecordJob).not_to receive(:perform_async)
        expect { subject }.to change(Agent, :count).by(-1)
      end
    end
  end
end
