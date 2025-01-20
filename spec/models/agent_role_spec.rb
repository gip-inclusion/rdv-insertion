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

  describe "access_level inclusion validation" do
    context "correct access_level value" do
      let(:agent_role) { build(:agent_role, access_level: "basic") }
      let(:agent_role2) { build(:agent_role, access_level: "admin") }

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

  describe "authorized to export csv when admin" do
    context "on record creation" do
      let!(:agent_role) { build(:agent_role, access_level: "admin", authorized_to_export_csv: false) }

      it "marks as authorized to export csv when admin" do
        agent_role.save!
        expect(agent_role.reload.authorized_to_export_csv).to eq(true)
      end

      it "does not mark as authorized when not admin" do
        agent_role.access_level = "basic"
        agent_role.save!
        expect(agent_role.reload.authorized_to_export_csv).to eq(false)
      end
    end

    context "on record update" do
      context "from basic to admin" do
        let!(:agent_role) { create(:agent_role, access_level: "basic", authorized_to_export_csv: false) }

        it "marks as authorized to export csv when admin" do
          agent_role.access_level = "admin"
          agent_role.save!
          expect(agent_role.reload.authorized_to_export_csv).to eq(true)
        end
      end

      context "from admin to basic" do
        let!(:agent_role) { create(:agent_role, access_level: "admin", authorized_to_export_csv: true) }

        it "does not mark as authorized when not admin" do
          agent_role.access_level = "basic"
          agent_role.save!
          expect(agent_role.reload.authorized_to_export_csv).to eq(false)
        end
      end
    end
  end

  describe "organisation cannot be archived" do
    let(:organisation) { create(:organisation, archived_at: Time.current) }
    let(:agent_role) { build(:agent_role, organisation: organisation) }

    it "adds an error" do
      expect(agent_role).not_to be_valid
    end
  end
end
