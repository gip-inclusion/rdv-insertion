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

  describe "retrying on an unauthorized response" do
    subject(:request_organisation) { client.get_organisation(1) }

    let(:client) { described_class.new(authentication: authentication) }
    let(:url) { "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/organisations/1" }

    context "when the authentication can be renewed" do
      let(:authentication) { instance_double(RdvSolidaritesAuthentication::Oauth, renewable?: true, renew!: nil) }

      before do
        allow(authentication).to receive(:headers).and_return(
          { "Authorization" => "Bearer expired" }, { "Authorization" => "Bearer fresh" }
        )
      end

      it "renews the credentials and replays the request with the new ones" do
        stub_request(:get, url).with(headers: { "Authorization" => "Bearer expired" }).to_return(status: 401)
        replayed = stub_request(:get, url)
                   .with(headers: { "Authorization" => "Bearer fresh" }).to_return(status: 200, body: {}.to_json)

        request_organisation

        expect(authentication).to have_received(:renew!)
        expect(replayed).to have_been_requested
      end
    end

    context "when the authentication cannot be renewed" do
      let(:authentication) do
        instance_double(
          RdvSolidaritesAuthentication::SharedSecret, renewable?: false, headers: { "uid" => "agent@gouv.fr" }
        )
      end

      it "returns the unauthorized response without replaying" do
        stubbed_request = stub_request(:get, url).to_return(status: 401)

        expect(request_organisation.status).to eq(401)
        expect(stubbed_request).to have_been_requested.once
      end
    end
  end
end
