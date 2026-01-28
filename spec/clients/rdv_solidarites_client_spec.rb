describe RdvSolidaritesClient do
  describe "connection settings" do
    let(:auth_headers) { { "Authorization" => "Bearer token" } }
    let(:client) { described_class.new(auth_headers: auth_headers) }

    it "uses the default open_timeout" do
      expect(client.send(:connection).options.open_timeout).to eq(10)
    end

    it "uses a 60s timeout by default" do
      expect(client.send(:connection).options.timeout).to eq(60)
    end

    it "allows timeout override via environment variable" do
      allow(ENV).to receive(:fetch).with("RDV_SOLIDARITES_TIMEOUT", 60).and_return("120")
      new_client = described_class.new(auth_headers: auth_headers)

      expect(new_client.send(:connection).options.timeout).to eq(120)
    end
  end
end
