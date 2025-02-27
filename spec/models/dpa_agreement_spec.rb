describe DpaAgreement do
  subject do
    dpa_agreement.save!
  end

  let!(:agent) { create(:agent) }
  let!(:organisation) { create(:organisation, :without_dpa_agreement) }
  let(:dpa_agreement) { build(:dpa_agreement, agent:, organisation:) }

  describe "callbacks" do
    it "saves agent identity" do
      subject
      expect(dpa_agreement.email).to eq(agent.email)
      expect(dpa_agreement.agent_full_name).to eq(agent.to_s)
    end

    context "agent change" do
      let(:other_agent) { create(:agent) }

      it "refresh agent identity" do
        subject
        dpa_agreement.update!(agent: other_agent)
        expect(dpa_agreement.agent_email).to eq(other_agent.email)
        expect(dpa_agreement.agent_full_name).to eq(other_agent.to_s)
      end
    end
  end

  describe "validations" do
    let!(:agent) { nil }

    it "requires an agent on creation" do
      expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
