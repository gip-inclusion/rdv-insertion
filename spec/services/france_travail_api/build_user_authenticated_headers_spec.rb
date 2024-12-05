describe FranceTravailApi::BuildUserAuthenticatedHeaders, type: :service do
  subject do
    described_class.call(user: user)
  end

  let(:user) { create(:user) }
  let(:access_token) { "access-token" }
  let(:user_token) { "user-token" }

  before do
    allow(FranceTravailApi::RetrieveAccessToken).to receive(:call)
      .and_return(OpenStruct.new(access_token: access_token, success?: true))
    allow(FranceTravailApi::RetrieveUserToken).to receive(:call)
      .and_return(OpenStruct.new(user_token: user_token, success?: true))
  end

  describe "#call" do
    it "returns headers with correct structure" do
      subject
      expect(subject.headers).to eq({
                                      "ft-jeton-usager" => user_token,
                                      "Authorization" => "Bearer #{access_token}",
                                      "Content-Type" => "application/json",
                                      "Accept" => "application/json",
                                      "pa-identifiant-agent" => "BATCH",
                                      "pa-nom-agent" => "Webhooks Participation RDV-Insertion",
                                      "pa-prenom-agent" => "Webhooks Participation RDV-Insertion"
                                    })
    end
  end
end
