describe FranceTravailClient do
  let(:client) { described_class.new(user: user) }
  let(:user) { create(:user) }
  let(:payload) { { some: "data" } }
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
      response = client.create_participation(payload: payload)
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
      response = client.update_participation(payload: payload)
      expect(response.status).to eq(200)
    end
  end

  describe "#delete_participation" do
    before do
      stub_request(
        :delete,
        "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rendez-vous-partenaire/v1/rendez-vous/#{france_travail_id}"
      )
        .with(headers: headers)
        .to_return(status: 200, body: "", headers: {})
    end

    it "sends a DELETE request to France Travail API" do
      response = client.delete_participation(france_travail_id: france_travail_id)
      expect(response.status).to eq(200)
    end
  end

  describe "#user_token" do
    before do
      stub_request(:post, "#{ENV['FRANCE_TRAVAIL_API_URL']}/partenaire/rechercher-usager/v1/usagers/recherche")
        .with(body: payload.to_json, headers: headers)
        .to_return(status: 200, body: "", headers: {})
    end

    it "sends a POST request to France Travail API" do
      response = client.retrieve_user_token(payload: payload)
      expect(response.status).to eq(200)
    end
  end

  describe "#request_headers" do
    context "when user is present" do
      it "returns user authenticated headers" do
        expect(client.request_headers).to eq(headers)
      end
    end

    context "when user is not present" do
      let(:client) { described_class.new }
      let(:access_token) { "client-token" }

      before do
        allow(FranceTravailApi::RetrieveAccessToken).to receive(:call)
          .and_return(OpenStruct.new(access_token: access_token))
      end

      it "returns client headers" do
        expect(client.request_headers).to eq({
                                               "Authorization" => "Bearer #{access_token}",
                                               "Content-Type" => "application/json"
                                             })
      end
    end
  end
end
