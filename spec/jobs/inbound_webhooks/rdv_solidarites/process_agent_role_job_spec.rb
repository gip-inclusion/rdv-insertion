describe InboundWebhooks::RdvSolidarites::ProcessAgentRoleJob do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "access_level" => "basic",
      "agent" => {
        "id" => rdv_solidarites_agent_id,
        "email" => "linus@linux.com",
        "first_name" => "Linus",
        "last_name" => "Torvalds"
      },
      "organisation" => { "id" => rdv_solidarites_organisation_id }
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_organisation_id) { 222 }
  let!(:rdv_solidarites_agent_id) { 455 }

  let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id) }
  let!(:agent) { create(:agent, rdv_solidarites_agent_id: rdv_solidarites_agent_id) }

  let!(:meta) do
    {
      "model" => "AgentRole",
      "timestamp" => "2023-02-09 11:17:22 +0200",
      "event" => "created"
    }.deep_symbolize_keys
  end

  describe "#perform" do
    context "when the agent does not belong to the org" do
      it "attaches the agent to the org" do
        subject
        agent_role = agent.reload.agent_roles.find_by(organisation: organisation)
        expect(agent_role).to have_attributes(
          access_level: "basic",
          last_webhook_update_received_at: "2023-02-09 11:17:22 +0200".to_datetime
        )
      end
    end

    context "when the agent already belongs to the org" do
      let!(:agent_role) do
        create(:agent_role, organisation: organisation, agent: agent, access_level: "basic")
      end

      it "updates the agent role" do
        data[:access_level] = "admin"
        subject
        expect(agent_role.reload.access_level).to eq("admin")
      end

      it "does not create another agent role" do
        expect { subject }.not_to change(AgentRole, :count)
      end
    end

    context "when the agent cannot be found" do
      let!(:agent) { create(:agent, rdv_solidarites_agent_id: 456) }

      it "creates the agent and attaches it to the org" do
        expect { subject }.to change(Agent, :count).by(1)
        new_agent = Agent.find_by(rdv_solidarites_agent_id: rdv_solidarites_agent_id)
        expect(new_agent).to have_attributes(
          email: "linus@linux.com",
          first_name: "Linus",
          last_name: "Torvalds",
          last_webhook_update_received_at: "2023-02-09 11:17:22 +0200".to_datetime
        )
        expect(new_agent.agent_roles.find_by(organisation: organisation)).to have_attributes(access_level: "basic")
      end
    end

    context "for destroyed event" do
      let!(:agent_role) do
        create(:agent_role, organisation: organisation, agent: agent)
      end

      let!(:meta) do
        {
          "model" => "AgentRole",
          "event" => "destroyed"
        }.deep_symbolize_keys
      end

      it "removes the agent from the organisation" do
        expect { subject }.to change(AgentRole, :count).by(-1)
      end

      context "when the agent belongs to this org only" do
        it "destroys the agent" do
          expect { subject }.to change(Agent, :count).by(-1)
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

      context "when the agent cannot be found" do
        let!(:agent) { create(:agent, rdv_solidarites_agent_id: 456) }

        it "does not remove any agent role" do
          expect { subject }.not_to change(AgentRole, :count)
        end
      end
    end

    context "for an intervenant" do
      let!(:agent_role) do
        create(:agent_role, organisation: organisation, agent: agent)
      end

      let!(:data) do
        {
          "access_level" => "intervenant",
          "agent" => {
            "id" => rdv_solidarites_agent_id,
            "email" => nil,
            "first_name" => nil,
            "last_name" => "Torvalds"
          },
          "organisation" => { "id" => rdv_solidarites_organisation_id }
        }.deep_symbolize_keys
      end

      let!(:meta) do
        {
          "model" => "AgentRole",
          "timestamp" => "2023-02-09 11:17:22 +0200",
          "event" => "updated"
        }.deep_symbolize_keys
      end

      it "removes the agent from the organisation" do
        expect { subject }.to change(AgentRole, :count).by(-1)
      end

      it "destroys the agent" do
        expect { subject }.to change(Agent, :count).by(-1)
      end

      it "archives the organisation left without agents" do
        subject
        expect(organisation.reload).to be_archived
      end

      context "when the agent cannot be found" do
        let!(:agent) { create(:agent, rdv_solidarites_agent_id: 456) }

        it "does not create the agent" do
          expect { subject }.not_to change(Agent, :count)
        end
      end
    end

    context "when organisation cannot be found" do
      let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: 2131) }

      it "does not attach the agent to the organisation" do
        expect { subject }.not_to change(AgentRole, :count)
      end
    end

    context "when the organisation is archived" do
      let!(:organisation) do
        create(
          :organisation,
          rdv_solidarites_organisation_id: rdv_solidarites_organisation_id, archived_at: Time.current
        )
      end
      let!(:agent) { create(:agent, rdv_solidarites_agent_id: 456) }

      it "does not create the agent" do
        expect { subject }.not_to change(Agent, :count)
      end

      it "does not attach the agent to the organisation" do
        expect { subject }.not_to change(AgentRole, :count)
      end
    end
  end
end
