describe Agent do
  describe "agent email uniqueness validation" do
    context "no collision" do
      let(:agent) { build(:agent, email: "johndoe@example.com") }

      it { expect(agent).to be_valid }
    end

    context "colliding emails" do
      let!(:agent_existing) { create(:agent, email: "johndoe@example.com") }
      let(:agent) { build(:agent, email: "johndoe@example.com") }

      it "adds errors" do
        expect(agent).not_to be_valid
        expect(agent.errors.details).to eq({ email: [{ error: :taken, value: "johndoe@example.com" }] })
        expect(agent.errors.full_messages.to_sentence)
          .to include("Email est déjà utilisé")
      end
    end
  end

  describe "agent email presence validation" do
    context "with no email" do
      let(:agent) { build(:agent, email: "") }

      it "is not valid" do
        expect(agent).not_to be_valid
        expect(agent.errors.details).to eq({ email: [{ error: :blank }] })
      end
    end
  end

  describe "cannot save as super admin" do
    let!(:agent) { create(:agent, super_admin: false) }

    it "cannot update" do
      expect(agent.update(super_admin: true)).to eq(false)
      expect(agent.errors.full_messages.to_sentence).to include("Super admin ne peut pas être mis à jour")
    end

    context "on creation" do
      let!(:agent) { build(:agent) }

      it "is not valid" do
        agent.super_admin = true
        expect(agent).not_to be_valid
        expect(agent.errors.full_messages.to_sentence).to include("Super admin ne peut pas être mis à jour")
      end
    end
  end

  describe "admins are always authorized to export" do
    let!(:organisation) { create(:organisation) }
    let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }

    it { expect(agent.export_organisations_ids).to include(organisation.id) }
  end

  describe "deletion" do
    subject { agent.destroy! }

    let!(:agent) { create(:agent) }

    context "dpa_agreement" do
      let!(:organisation) { create(:organisation, :without_dpa_agreement) }
      let!(:dpa_agreement) { create(:dpa_agreement, agent:, organisation:) }

      it "nullifies dpa_agreement" do
        subject
        dpa_agreement.reload

        expect(dpa_agreement.agent).to be_nil
        expect(dpa_agreement.agent_email).to eq(agent.email)
      end
    end
  end

  describe "tracking_accepted?" do
    let(:agent) { create(:agent) }

    it "returns false if no cookies consent" do
      expect(agent).not_to be_tracking_accepted
    end

    context "with cookies consent" do
      let!(:cookies_consent) { create(:cookies_consent, agent:, tracking_accepted: true) }

      it "returns true if tracking accepted" do
        expect(agent).to be_tracking_accepted
      end

      it "returns false if tracking not accepted" do
        cookies_consent.update!(tracking_accepted: false)
        expect(agent).not_to be_tracking_accepted
      end
    end
  end

  describe "support_accepted?" do
    let(:agent) { create(:agent) }

    it "returns false if no cookies consent" do
      expect(agent).not_to be_support_accepted
    end

    context "with cookies consent" do
      let!(:cookies_consent) { create(:cookies_consent, agent:, support_accepted: true) }

      it "returns true if support accepted" do
        expect(agent).to be_support_accepted
      end

      it "returns false if support not accepted" do
        cookies_consent.update!(support_accepted: false)
        expect(agent).not_to be_support_accepted
      end
    end
  end
end
