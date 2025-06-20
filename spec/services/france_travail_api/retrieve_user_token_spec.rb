describe FranceTravailApi::RetrieveUserToken do
  subject do
    described_class.call(user: user, access_token: access_token)
  end

  let(:user) { create(:user, birth_date: "1990-01-01", nir: "1900167890123") }
  let(:access_token) { "access-token" }
  let(:france_travail_client) { FranceTravailClient }
  let(:headers) do
    {
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "application/json",
      "pa-identifiant-agent" => "BATCH",
      "pa-nom-agent" => "Webhooks Participation RDV-Insertion",
      "pa-prenom-agent" => "Webhooks Participation RDV-Insertion"
    }
  end

  before do
    allow(FranceTravailApi::RetrieveAccessToken).to receive(:call)
      .and_return(OpenStruct.new(access_token: access_token))
  end

  describe "#call" do
    context "when user has NIR" do
      let(:expected_payload) do
        {
          dateNaissance: user.birth_date.to_s,
          nir: user.nir
        }
      end

      context "when the API call is successful" do
        let(:user_token) { "user-token-123" }
        let(:response_body) { { "jetonUsager" => user_token, "codeRetour" => "S001" }.to_json }

        before do
          allow(france_travail_client).to receive(:retrieve_user_token_by_nir)
            .with(payload: expected_payload, headers: headers)
            .and_return(OpenStruct.new(success?: true, body: response_body))
        end

        it "returns the user token" do
          subject
          expect(subject.user_token).to eq(user_token)
        end

        context "when no matching user is found" do
          let(:response_body) { { "jetonUsager" => nil, "codeRetour" => "S003" }.to_json }

          it "returns an error" do
            expect { subject }.to raise_error(FranceTravailApi::RetrieveUserToken::NoMatchingUser)
          end
        end
      end

      context "when the API call fails" do
        let(:response_body) { { "jetonUsager" => nil, "codeRetour" => "R001" }.to_json }

        before do
          allow(france_travail_client).to receive(:retrieve_user_token_by_nir)
            .with(payload: expected_payload, headers: headers)
            .and_return(OpenStruct.new(success?: false, status: 400, body: response_body))
        end

        it("is a failure") { is_a_failure }

        it "returns the error" do
          expect(subject.errors).to eq(
            ["Erreur lors de l'appel à l'api recherche-usager FT.\nStatus: 400\n Body: #{response_body}"]
          )
        end
      end

      context "when user has a valid NIR and a valid France Travail ID" do
        let(:user) { create(:user, birth_date: "1990-01-01", nir: "1900167890123", france_travail_id: "12345678901") }
        let(:expected_payload) do
          {
            dateNaissance: user.birth_date.to_s,
            nir: user.nir
          }
        end
        let(:user_token) { "user-token-123" }
        let(:response_body) { { "jetonUsager" => user_token, "codeRetour" => "S001" }.to_json }

        before do
          allow(france_travail_client).to receive(:retrieve_user_token_by_nir)
            .with(payload: expected_payload, headers: headers)
            .and_return(OpenStruct.new(success?: true, body: response_body))
        end

        it "returns the user token (authenticate with NIR)" do
          subject
          expect(subject.user_token).to eq(user_token)
        end
      end
    end

    context "when user has no NIR but has valid France Travail ID" do
      let(:user) { create(:user, nir: nil, france_travail_id: "12345678901") }
      let(:expected_payload) do
        {
          numeroFranceTravail: user.france_travail_id
        }
      end

      context "when the API call is successful" do
        let(:user_token) { "user-token-456" }
        let(:response_body) { { "jetonUsager" => user_token, "codeRetour" => "S001" }.to_json }

        before do
          allow(france_travail_client).to receive(:retrieve_user_token_by_france_travail_id)
            .with(payload: expected_payload, headers: headers)
            .and_return(OpenStruct.new(success?: true, body: response_body))
        end

        it "returns the user token" do
          subject
          expect(subject.user_token).to eq(user_token)
        end
      end
    end
  end
end
