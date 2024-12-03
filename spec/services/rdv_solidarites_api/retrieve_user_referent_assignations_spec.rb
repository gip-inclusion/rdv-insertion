describe RdvSolidaritesApi::RetrieveUserReferentAssignations, type: :service do
  subject do
    described_class.call(rdv_solidarites_user_id:)
  end

  let(:rdv_solidarites_user_id) { 42 }

  let(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }

  let(:referent_assignations) do
    [{
      "id" => 1,
      "agent" => {
        "id" => 2,
        "email" => "linus@linux.com"
      },
      "user" => {
        "id" => 3,
        "email" => "james@linux.com"
      }
    }]
  end

  before do
    allow(Current).to receive(:rdv_solidarites_client).and_return(rdv_solidarites_client)
    allow(rdv_solidarites_client).to receive(:get_user_referent_assignations)
      .with(rdv_solidarites_user_id)
      .and_return(OpenStruct.new(success?: true, body: { "referent_assignations" => referent_assignations }.to_json))
  end

  describe "#call" do
    it "retrieves the user referent assignation" do
      expect(rdv_solidarites_client).to receive(:get_user_referent_assignations).with(rdv_solidarites_user_id)
      subject
    end

    it "returns the user referent assignations" do
      expect(subject.referent_assignations.map(&:agent).map(&:id)).to contain_exactly(2)
    end

    context "when it fails" do
      before do
        allow(rdv_solidarites_client).to receive(:get_user_referent_assignations).and_return(
          OpenStruct.new(success?: false, body: { error_messages: ["some error"] }.to_json)
        )
      end

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Erreur RDV-Solidarités: some error"])
      end
    end
  end
end
