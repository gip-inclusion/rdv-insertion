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
end
