describe AgentRole do
  describe "rdv_solidarites_agent_role_id uniqueness validation" do
    context "no collision" do
      let(:agent_role) { build(:agent_role, rdv_solidarites_agent_role_id: 1) }

      it { expect(agent_role).to be_valid }
    end

    context "blank rdv_solidarites_agent_role_id" do
      let!(:agent_role_existing) { create(:agent_role, rdv_solidarites_agent_role_id: 1) }

      let(:agent_role) { build(:agent_role, rdv_solidarites_agent_role_id: "") }

      it { expect(agent_role).to be_valid }
    end

    context "colliding rdv_solidarites_agent_role_id" do
      let!(:agent_role_existing) { create(:agent_role, rdv_solidarites_agent_role_id: 1) }
      let(:agent_role) { build(:agent_role, rdv_solidarites_agent_role_id: 1) }

      it "adds errors" do
        expect(agent_role).not_to be_valid
        expect(agent_role.errors.details).to eq({ rdv_solidarites_agent_role_id: [{ error: :taken, value: 1 }] })
        expect(agent_role.errors.full_messages.to_sentence)
          .to include("Rdv solidarites agent role est déjà utilisé")
      end
    end
  end

  describe "level inclusion validation" do
    context "correct level value" do
      let(:agent_role) { build(:agent_role, level: "basic") }
      let(:agent_role2) { build(:agent_role, level: "admin") }

      it { expect(agent_role).to be_valid }
      it { expect(agent_role2).to be_valid }
    end
  end

  describe "agent/organisation uniqueness association" do
    context "no collision" do
      let!(:agent) { create(:agent) }
      let!(:organisation) { create(:organisation) }
      let!(:other_organisation) { create(:organisation) }
      let(:agent_role_existing) { create(:agent_role, agent: agent, organisation: organisation) }
      let(:agent_role) { build(:agent_role, agent: agent, organisation: other_organisation) }

      it { expect(agent_role).to be_valid }
    end

    context "colliding agent/organisation couple" do
      let!(:agent) { create(:agent) }
      let!(:organisation) { create(:organisation) }
      let(:agent_role) { build(:agent_role, agent: agent, organisation: organisation) }
      let(:colliding_agent_role) { build(:agent_role, agent: agent, organisation: organisation) }

      it "add_errors" do
        expect { agent_role.save }.to change(described_class, :count).by(1)
        expect(colliding_agent_role).not_to be_valid
        expect(colliding_agent_role.errors.full_messages.to_sentence)
          .to include("Agent est déjà relié à l'organisation")
      end
    end
  end
end
