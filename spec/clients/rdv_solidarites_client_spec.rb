describe RdvSolidaritesClient do
  describe "connection settings" do
    let(:authentication) { RdvSolidaritesAuthentication::StaticHeaders.new(headers: { "Authorization" => "Bearer token" }) }
    let(:client) { described_class.new(authentication: authentication) }

    it "uses the default open_timeout" do
      expect(client.send(:connection).options.open_timeout).to eq(30)
    end

    it "uses a 60s timeout by default" do
      expect(client.send(:connection).options.timeout).to eq(60)
    end

    it "allows timeout override via environment variable" do
      allow(ENV).to receive(:fetch).with("RDV_SOLIDARITES_TIMEOUT", 60).and_return("120")
      allow(ENV).to receive(:fetch).with("RDV_SOLIDARITES_OPEN_TIMEOUT", 30).and_return("60")
      new_client = described_class.new(authentication: authentication)

      expect(new_client.send(:connection).options.timeout).to eq(120)
      expect(new_client.send(:connection).options.open_timeout).to eq(60)
    end
  end
end
