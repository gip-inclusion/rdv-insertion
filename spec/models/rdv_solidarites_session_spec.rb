describe RdvSolidaritesSession do
  describe ".from" do
    context "with :login provider" do
      it "returns LoginSession" do
        expect(described_class.from(:login)).to eq(LoginSession)
      end
    end

    context "with :inclusion_connect provider" do
      it "returns InclusionConnectSession" do
        expect(described_class.from(:inclusion_connect)).to eq(InclusionConnectSession)
      end
    end

    context "with unknown provider" do
      it "raises an error" do
        lambda do
          described_class.from(:other_prov)
        end.should raise_error(RuntimeError, "session provider other_prov unknown")
      end
    end
  end

  describe "#rdv_solidarites_client" do
    let(:rdv_solidarites_session) do
      described_class.from(:login).with(uid: uid, client: client, access_token: access_token)
    end

    let!(:uid) { "aminedhobb@beta.gouv.fr" }
    let!(:client) { "28FNFEJF" }
    let!(:access_token) { "EDZADZ" }

    it "returns an instance of RdvSolidaritesClient" do
      expect(rdv_solidarites_session.rdv_solidarites_client).to be_an_instance_of(RdvSolidaritesClient)
    end

    it "returns the same instance of RdvSolidaritesClient on subsequent calls" do
      first_call = rdv_solidarites_session.rdv_solidarites_client
      second_call = rdv_solidarites_session.rdv_solidarites_client
      expect(first_call).to equal(second_call)
    end
  end
end
