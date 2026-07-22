describe RdvSolidaritesAuthentication::Oauth do
  subject { described_class.new(agent: agent) }

  let(:agent) { create(:agent) }

  describe "#headers" do
    context "when the agent has an oauth token" do
      before { create(:rdv_solidarites_oauth_token, agent: agent, api_token: "some-token") }

      it "returns the bearer authorization header" do
        expect(subject.headers).to eq({ "Authorization" => "Bearer some-token" })
      end
    end

    context "when the agent has no oauth token" do
      it "raises a MissingCredentials error" do
        expect { subject.headers }.to raise_error(described_class::MissingCredentials)
      end
    end
  end

  describe "#renewable?" do
    context "when the agent has an oauth token" do
      before { create(:rdv_solidarites_oauth_token, agent: agent) }

      it { expect(subject.renewable?).to be(true) }
    end

    context "when the agent has no oauth token" do
      it { expect(subject.renewable?).to be(false) }
    end
  end

  describe "#renew!" do
    let!(:oauth_token) { create(:rdv_solidarites_oauth_token, agent: agent, api_token: "some-token") }

    before do
      allow(agent).to receive(:rdv_solidarites_oauth_token).and_return(oauth_token)
      allow(oauth_token).to receive(:refresh!)
    end

    it "refreshes the token with the current api token" do
      subject.renew!
      expect(oauth_token).to have_received(:refresh!).with("some-token")
    end
  end
end
