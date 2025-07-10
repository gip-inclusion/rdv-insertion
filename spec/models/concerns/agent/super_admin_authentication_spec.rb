describe Agent::SuperAdminAuthentication do
  let(:agent) { create(:agent, :super_admin) }

  describe "#generate_and_send_super_admin_authentication_request!" do
    subject { agent.generate_and_send_super_admin_authentication_request! }

    it "creates a new super admin authentication request" do
      expect { subject }.to change(SuperAdminAuthenticationRequest, :count).by(1)
    end

    it "sends an email with the token" do
      expect(SuperAdminMailer).to receive_message_chain(:send_authentication_token, :deliver_now!)
      subject
    end
  end

  describe "#super_admin_token_verified?" do
    subject { agent.super_admin_token_verified? }

    context "when the agent is not a super admin" do
      let(:agent) { create(:agent) }

      it { is_expected.to be_falsy }
    end

    context "when the agent is a super admin" do
      context "when there is no authentication request" do
        it { is_expected.to be_falsy }
      end

      context "when the last authentication request is not verified" do
        before { create(:super_admin_authentication_request, agent: agent, verified_at: nil) }

        it { is_expected.to be_falsy }
      end

      context "when the last authentication request is verified" do
        before { create(:super_admin_authentication_request, agent: agent, verified_at: Time.zone.now) }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe "#last_super_admin_authentication_request" do
    subject { agent.last_super_admin_authentication_request }

    let!(:first_request) { create(:super_admin_authentication_request, agent: agent, created_at: 2.hours.ago) }
    let!(:last_request) do
      create(:super_admin_authentication_request, agent: agent, created_at: 1.hour.ago, verified_at: Time.current)
    end

    it "returns the last request" do
      expect(subject).to eq(last_request)
    end
  end
end
