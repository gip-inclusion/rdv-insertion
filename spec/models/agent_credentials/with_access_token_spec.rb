describe AgentCredentials::WithAccessToken do
  subject do
    described_class.new(
      uid: uid, client: client, access_token: access_token
    )
  end

  let!(:uid) { "aminedhobb@beta.gouv.fr" }
  let!(:client) { "28FNFEJF" }
  let!(:access_token) { "EDZADZ" }

  describe "#valid?" do
    context "when all required attributes are present and token is valid" do
      before do
        allow_any_instance_of(RdvSolidaritesClient).to receive(:validate_token)
          .and_return(OpenStruct.new(success?: true, body: {
            data: { uid: uid }
          }.to_json))
      end

      it "credentials are valid" do
        expect(subject).to be_valid
      end
    end

    describe "#valid?" do
      context "when validate token responds with another uid" do
        before do
          allow_any_instance_of(RdvSolidaritesClient).to receive(:validate_token)
            .and_return(OpenStruct.new(success?: true, body: {
              data: { uid: "someagent@beta.gouv.fr" }
            }.to_json))
        end

        it "credentials are invalid" do
          expect(subject).not_to be_valid
        end
      end
    end

    context "when at least one required attribute is missing" do
      let(:uid) { nil }

      it "credentials are invalid" do
        expect(subject).not_to be_valid
      end
    end

    context "when validate_token is not valid" do
      before do
        allow_any_instance_of(RdvSolidaritesClient).to receive(:validate_token)
          .and_return(OpenStruct.new(success?: false))
      end

      it "credentials are invalid" do
        expect(subject).not_to be_valid
      end
    end
  end

  describe "#to_h" do
    it "returns a hash with the correct keys and values" do
      expect(subject.to_h).to eq(
        {
          "uid" => uid,
          "client" => client,
          "access-token" => access_token
        }
      )
    end
  end
end
