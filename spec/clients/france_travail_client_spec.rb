describe FranceTravailClient do
  let(:payload) { { nir: "1900167890123", dateNaissance: "1990-01-01" } }
  let(:france_travail_id) { "ft-123" }
  let(:headers) do
    { "Authorization" => "Bearer token", "Content-Type" => "application/json", "Accept" => "application/json",
      "ft-jeton-usager" => "jeton-usager" }
  end

  before do
    allow(FranceTravailApi::BuildUserAuthenticatedHeaders).to receive(:call)
      .and_return(OpenStruct.new(headers: headers))
  end

  describe "#create_participation" do
    before do
      stub_request(:post, "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rendez-vous-partenaire/v1/rendez-vous")
        .with(body: payload.to_json, headers: headers)
        .to_return(status: 200, body: "", headers: {})
    end

    it "sends a POST request to France Travail API" do
      response = described_class.create_participation(payload: payload, headers: headers)
      expect(response.status).to eq(200)
    end
  end

  describe "#update_participation" do
    before do
      stub_request(:put, "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rendez-vous-partenaire/v1/rendez-vous")
        .with(body: payload.to_json, headers: headers)
        .to_return(status: 200, body: "", headers: {})
    end

    it "sends a PUT request to France Travail API" do
      response = described_class.update_participation(payload: payload, headers: headers)
      expect(response.status).to eq(200)
    end
  end

  describe "#cancel_participation" do
    before do
      stub_request(
        :delete,
        "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rendez-vous-partenaire/v1/rendez-vous/#{france_travail_id}"
      )
        .with(headers: headers)
        .to_return(status: 200, body: "", headers: {})
    end

    it "sends a DELETE request to France Travail API" do
      response = described_class.cancel_participation(france_travail_id: france_travail_id, headers: headers)
      expect(response.status).to eq(200)
    end
  end

  describe "#retrieve_user_token_by_nir" do
    before do
      stub_request(
        :post,
        "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rechercher-usager/v2/usagers/par-datenaissance-et-nir"
      )
        .with(body: payload.to_json, headers: headers)
        .to_return(status: 200, body: "", headers: {})
    end

    it "sends a POST request to France Travail API with NIR endpoint" do
      response = described_class.retrieve_user_token_by_nir(payload: payload, headers: headers)
      expect(response.status).to eq(200)
    end
  end

  describe "#retrieve_user_token_by_france_travail_id" do
    let(:payload_with_france_travail_id) { { numeroFranceTravail: "12345678901" } }

    before do
      stub_request(
        :post,
        "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rechercher-usager/v2/usagers/par-numero-francetravail"
      )
        .with(body: payload_with_france_travail_id.to_json, headers: headers)
        .to_return(status: 200, body: "", headers: {})
    end

    it "sends a POST request to France Travail API with France Travail ID endpoint" do
      response = described_class.retrieve_user_token_by_france_travail_id(
        payload: payload_with_france_travail_id, headers: headers
      )
      expect(response.status).to eq(200)
    end
  end
end
