describe RdvSolidaritesWebhooks::ProcessReferentAssignationJob do
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

  let!(:user) do
    create(:user, rdv_solidarites_user_id: rdv_solidarites_user_id, referents: [agent])
  end

  let!(:agent) { create(:agent, rdv_solidarites_agent_id: rdv_solidarites_agent_id) }

  describe "#call" do
    it "removes the agent from the user" do
      subject
      expect(user.reload.referents).to eq([])
    end

    context "when the user cannot be found" do
      let!(:user) do
        create(:user, rdv_solidarites_user_id: "some-id", referents: [agent])
      end

      it "does not remove the organisation from the user" do
        subject
        expect(user.reload.referents).to eq([agent])
      end
    end

    context "when the agent cannot be found" do
      let!(:agent) do
        create(:agent, rdv_solidarites_agent_id: "some-orga")
      end

      it "does not remove the agent from the user" do
        subject
        expect(user.reload.referents).to eq([agent])
      end
    end

    context "when the event is updated" do
      let!(:meta) do
        {
          "model" => "ReferentAssignation",
          "event" => "updated"
        }.deep_symbolize_keys
      end

      it "does not remove the agent from the user" do
        subject
        expect(user.reload.referents).to eq([agent])
      end
    end

    context "when the event is created" do
      let!(:meta) do
        {
          "model" => "ReferentAssignation",
          "event" => "created"
        }.deep_symbolize_keys
      end

      context "when the user does not belong to the org" do
        let!(:user) do
          create(:user, rdv_solidarites_user_id: rdv_solidarites_user_id, referents: [])
        end

        it "adds the agent to the user" do
          subject
          expect(user.reload.referents.ids).to eq([agent.id])
        end
      end
    end
  end
end
