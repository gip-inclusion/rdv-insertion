describe UpsertAgent, type: :service do
  subject { described_class.call(email: agent.email, organisation_ids: organisation_ids) }

  let!(:agent) { create(:agent) }
  let!(:email) { agent.email }

  let!(:organisation_ids) { [] }

  describe "#call" do
    let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: 31) }
    let!(:organisation_ids) { [31, 42] }

    before do
      allow(Agent).to receive(:find_or_create_by)
        .with(email: email)
        .and_return(agent)
    end

    it "is a success" do
      expect(subject.success?).to eq(true)
    end

    it "finds or create the agent" do
      expect(Agent).to receive(:find_or_create_by)
        .with(email: email)
      subject
    end

    it "returns the agent" do
      expect(subject.agent).to eq(agent)
    end

    it "updates the agent by assigning the organisations" do
      subject
      expect(agent.organisations).to eq([organisation])
    end
  end
end
