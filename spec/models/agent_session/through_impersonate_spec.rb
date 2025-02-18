describe AgentSession::ThroughImpersonate do
  subject { described_class.new(id:, created_at:, signature:, origin:, super_admin_auth:) }

  let!(:id) { agent.id }
  let!(:agent) { create(:agent) }
  let!(:created_at) { Time.zone.now.to_i }
  let!(:signature) { agent.sign_with(created_at) }
  let!(:origin) { "impersonate" }

  let!(:super_admin) { create(:agent, :super_admin) }
  let!(:super_admin_session_timestamp) { Time.zone.now.to_i }
  let!(:super_admin_session_origin) { "sign_in_form" }
  let!(:super_admin_signature) { super_admin.sign_with(super_admin_session_timestamp) }
  let!(:super_admin_auth) do
    { id: super_admin.id, signature: super_admin_signature,
      origin: super_admin_session_origin, created_at: super_admin_session_timestamp }
  end

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

  context "70 minutes after its creation" do
    before { travel_to(70.minutes.from_now) }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "50 minutes after its creation" do
    before { travel_to(50.minutes.from_now) }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "when the super admin session is not valid" do
    let!(:super_admin_signature) { "random-signature" }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "when the super admin session does not belong to a super admin" do
    let!(:super_admin) { create(:agent, super_admin: false) }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "when the super admin session is through impersonate" do
    let!(:super_admin_session_origin) { "impersonate" }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "when the super admin session is impersonating himself" do
    let!(:agent) { create(:agent, :super_admin) }
    let!(:super_admin) { agent }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end
end
