describe "Api::V1 rdv-solidarités oauth token requirement", type: :request do
  let!(:agent) { create(:agent) }
  let(:headers) { { "uid" => agent.email, "client" => "someclient", "access-token" => "sometoken" } }

  before do
    stub_request(:get, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/auth/validate_token")
      .to_return(body: { "data" => { "uid" => agent.email } }.to_json)
  end

  context "when the authenticated agent has no oauth token" do
    it "returns unauthorized and asks the agent to sign in" do
      get "/api/v1/departments/1", headers: headers

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["errors"].join).to match(/vous connecter à RDV-Insertion/)
    end
  end
end
