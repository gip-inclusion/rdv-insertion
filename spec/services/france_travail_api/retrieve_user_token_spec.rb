describe FranceTravailApi::RetrieveUserToken do
  subject do
    described_class.call(user: user, access_token: access_token)
  end

  let(:user) { create(:user, birth_date: "1990-01-01", nir: "1900167890123") }
  let(:access_token) { "access-token" }
  let(:france_travail_client) { instance_double(FranceTravailClient) }

  before do
    allow(FranceTravailClient).to receive(:new).and_return(france_travail_client)
  end

  describe "#call" do
    let(:expected_payload) do
      {
        dateNaissance: user.birth_date.to_s,
        nir: user.nir
      }
    end

    context "when the API call is successful" do
      let(:user_token) { "user-token-123" }
      let(:response_body) { { "jetonUsager" => user_token }.to_json }

      before do
        allow(france_travail_client).to receive(:user_token)
          .with(payload: expected_payload)
          .and_return(OpenStruct.new(success?: true, body: response_body))
      end

      it "returns the user token" do
        subject
        expect(subject.user_token).to eq(user_token)
      end
    end

    context "when the API call fails" do
      before do
        allow(france_travail_client).to receive(:user_token)
          .with(payload: expected_payload)
          .and_return(OpenStruct.new(success?: false, status: 400, body: "Error"))
      end

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(
          ["Erreur lors de l'appel à l'api recherche-usager FT.\nStatus: 400\n Body: Error"]
        )
      end
    end
  end
end
