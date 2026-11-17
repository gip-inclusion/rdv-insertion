describe RdvSolidaritesClient do
  describe "connection settings" do
    let(:agent) { build(:agent) }
    let(:client) { described_class.new(agent: agent) }

    it "uses the default open_timeout" do
      expect(client.send(:connection).options.open_timeout).to eq(30)
    end

    it "uses a 60s timeout by default" do
      expect(client.send(:connection).options.timeout).to eq(60)
    end

    it "allows timeout override via environment variable" do
      allow(ENV).to receive(:fetch).with("RDV_SOLIDARITES_TIMEOUT", 60).and_return("120")
      allow(ENV).to receive(:fetch).with("RDV_SOLIDARITES_OPEN_TIMEOUT", 30).and_return("60")
      new_client = described_class.new(agent: agent)

      expect(new_client.send(:connection).options.timeout).to eq(120)
      expect(new_client.send(:connection).options.open_timeout).to eq(60)
    end
  end

  describe "retrying on an unauthorized response" do
    subject(:request_organisation) { client.get_organisation(1) }

    let(:client) { described_class.new(agent: agent) }
    let(:url) { "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/organisations/1" }

    let(:agent) { create(:agent) }
    let(:oauth_token) { create(:rdv_solidarites_oauth_token, agent: agent, api_token: "expired") }

    before do
      allow(agent).to receive(:rdv_solidarites_oauth_token).and_return(oauth_token)
      allow(oauth_token).to receive(:refresh!) { oauth_token.api_token = "fresh" }
    end

    it "renews the credentials and replays the request with the new ones" do
      stub_request(:get, url).with(headers: { "Authorization" => "Bearer expired" }).to_return(status: 401)
      replayed = stub_request(:get, url)
                 .with(headers: { "Authorization" => "Bearer fresh" }).to_return(status: 200, body: {}.to_json)

      request_organisation

      expect(oauth_token).to have_received(:refresh!).with("expired")
      expect(replayed).to have_been_requested
    end
  end
end
