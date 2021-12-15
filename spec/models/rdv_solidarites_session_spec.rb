describe RdvSolidaritesSession do
  subject { described_class.new(uid: uid, client: client, access_token: access_token) }

  let!(:uid) { "aminedhobb@beta.gouv.fr" }
  let!(:client) { "28FNFEJF" }
  let!(:access_token) { "EDZADZ" }
  let!(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }

  before do
    allow(RdvSolidaritesClient).to receive(:new)
      .with(rdv_solidarites_session: subject)
      .and_return(rdv_solidarites_client)
  end

  describe "#valid?" do
    before do
      allow(rdv_solidarites_client).to receive(:validate_token)
        .and_return(OpenStruct.new(success?: true, body: {
          data: { uid: uid }
        }.to_json))
    end

    it "is valid" do
      expect(subject.valid?).to eq(true)
    end

    context "when one session parameters is not present" do
      let(:uid) { "" }

      it "is invalid" do
        expect(subject.valid?).to eq(false)
      end
    end

    context "when validate_token response is not a success" do
      before do
        allow(rdv_solidarites_client).to receive(:validate_token)
          .and_return(OpenStruct.new(success?: false))
      end

      it "is invalid" do
        expect(subject.valid?).to eq(false)
      end
    end

    context "when validate token responds with another uid" do
      before do
        allow(rdv_solidarites_client).to receive(:validate_token)
          .and_return(OpenStruct.new(success?: true, body: {
            data: { uid: "someagent@beta.gouv.fr" }
          }.to_json))
      end

      it "is invalid" do
        expect(subject.valid?).to eq(false)
      end
    end
  end
end
