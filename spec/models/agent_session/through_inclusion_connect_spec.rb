describe AgentSession::ThroughInclusionConnect do
  subject { described_class.new(id:, created_at:, signature:, origin:, inclusion_connect_token_id:) }

  let!(:id) { agent.id }
  let!(:agent) { create(:agent) }
  let!(:created_at) { Time.zone.now.to_i }
  let!(:signature) { agent.sign_with(created_at) }
  let!(:origin) { "inclusion_connect" }
  let!(:inclusion_connect_token_id) { "1234" }

  it "is valid" do
    expect(subject).to be_valid
  end

  it "retrieves the agent" do
    expect(subject.agent).to eq(agent)
  end

  context "when an agent cannot be retrieved through the id" do
    let!(:id) { "12312421142" }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "when the signature is not valid" do
    let!(:signature) { "random-signature" }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "when the origin is not valid" do
    let!(:origin) { "sign_in_form" }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "8 days after its creation" do
    before { travel_to(8.days.from_now) }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "6 days after its creation" do
    before { travel_to(6.days.from_now) }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  describe "#inclusion_connect?" do
    it "is marked as an inclusion connect session" do
      expect(subject.inclusion_connect?).to eq(true)
    end
  end

  describe "#inclusion_connect_token_id" do
    it "exposes the inclusion_connect_token_id" do
      expect(subject.inclusion_connect_token_id).to eq(inclusion_connect_token_id)
    end
  end
end
