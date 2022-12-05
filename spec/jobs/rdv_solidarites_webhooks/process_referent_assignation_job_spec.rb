describe RdvSolidaritesWebhooks::ProcessReferentAssignationJob, type: :job do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "user" => { "id" => rdv_solidarites_user_id },
      "agent" => { "id" => rdv_solidarites_agent_id }
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_user_id) { 22 }
  let!(:rdv_solidarites_agent_id) { 18 }

  let!(:meta) do
    {
      "model" => "ReferentAssignation",
      "event" => "destroyed"
    }.deep_symbolize_keys
  end

  let!(:applicant) do
    create(:applicant, rdv_solidarites_user_id: rdv_solidarites_user_id, agents: [agent])
  end

  let!(:agent) { create(:agent, rdv_solidarites_agent_id: rdv_solidarites_agent_id) }

  describe "#call" do
    it "removes the agent from the applicant" do
      subject
      expect(applicant.reload.agents).to eq([])
    end

    context "when the applicant cannot be found" do
      let!(:applicant) do
        create(:applicant, rdv_solidarites_user_id: "some-id", agents: [agent])
      end

      it "does not remove the organisation from the applicant" do
        subject
        expect(applicant.reload.agents).to eq([agent])
      end
    end

    context "when the agent cannot be found" do
      let!(:agent) do
        create(:agent, rdv_solidarites_agent_id: "some-orga")
      end

      before do
        allow(MattermostClient).to receive(:send_to_notif_channel)
      end

      it "does not remove the agent from the applicant" do
        subject
        expect(applicant.reload.agents).to eq([agent])
      end

      it "sends a notification to mattermost" do
        expect(MattermostClient).to receive(:send_to_notif_channel).with(
          "Referent not found for RDV-S referent assignation.\n" \
          "agent id: #{rdv_solidarites_agent_id}\n" \
          "user id: #{rdv_solidarites_user_id}"
        )
        subject
      end
    end

    context "when the event is updated" do
      let!(:meta) do
        {
          "model" => "ReferentAssignation",
          "event" => "updated"
        }.deep_symbolize_keys
      end

      it "does not remove the agent from the applicant" do
        subject
        expect(applicant.reload.agents).to eq([agent])
      end
    end

    context "when the event is created" do
      let!(:meta) do
        {
          "model" => "ReferentAssignation",
          "event" => "created"
        }.deep_symbolize_keys
      end

      context "when the applicant does not belong to the org" do
        let!(:applicant) do
          create(:applicant, rdv_solidarites_user_id: rdv_solidarites_user_id, agents: [])
        end

        it "adds the agent to the applicant" do
          subject
          expect(applicant.reload.agents.ids).to eq([agent.id])
        end
      end
    end
  end
end
