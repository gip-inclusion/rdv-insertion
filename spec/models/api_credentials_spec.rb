describe ApiCredentials do
  subject { described_class.new(uid:, client:, access_token:) }

  let!(:uid) { "aminedhobb@beta.gouv.fr" }
  let!(:client) { "28FNFEJF" }
  let!(:access_token) { "EDZADZ" }
  let(:validate_token_url) { "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/auth/validate_token" }

  describe "#valid?" do
    context "when all attributes are present and the token is valid" do
      before do
        stub_request(:get, validate_token_url).to_return(status: 200, body: { data: { uid: uid } }.to_json)
      end

      it { is_expected.to be_valid }
    end

    context "when validate_token responds with another uid" do
      before do
        stub_request(:get, validate_token_url)
          .to_return(status: 200, body: { data: { uid: "someagent@beta.gouv.fr" } }.to_json)
      end

      it { is_expected.not_to be_valid }
    end

    context "when a required attribute is missing" do
      let(:uid) { nil }

      it { is_expected.not_to be_valid }
    end

    context "when validate_token is unauthorized" do
      before { stub_request(:get, validate_token_url).to_return(status: 401) }

      it { is_expected.not_to be_valid }
    end
  end
end
