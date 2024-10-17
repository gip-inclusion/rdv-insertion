describe RdvSolidaritesApi::RetrieveUser, type: :service do
  subject do
    described_class.call(rdv_solidarites_user_id:)
  end

  let(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }
  let!(:rdv_solidarites_user_id) { 1717 }

  describe "#call" do
    let!(:user_attributes) do
      {
        "id" => 1717,
        "first_name" => "Léonard",
        "last_name" => "De Vinci"
      }
    end

    before do
      allow(Current).to receive(:rdv_solidarites_client).and_return(rdv_solidarites_client)
      allow(rdv_solidarites_client).to receive(:get_user)
        .with(rdv_solidarites_user_id)
        .and_return(OpenStruct.new(success?: true, body: { "user" => user_attributes }.to_json))
    end

    context "when it succeeds" do
      it("is a success") { is_a_success }

      it "calls the rdv solidarites client" do
        expect(rdv_solidarites_client).to receive(:get_user)
        subject
      end

      it "returns the user" do
        expect(subject.user.id).to eq(rdv_solidarites_user_id)
        expect(subject.user.first_name).to eq("Léonard")
        expect(subject.user.last_name).to eq("De Vinci")
      end
    end

    context "when it fails" do
      before do
        allow(rdv_solidarites_client).to receive(:get_user)
          .and_return(OpenStruct.new(success?: false, body: { error_messages: ["some error"] }.to_json))
      end

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Erreur RDV-Solidarités: some error"])
      end
    end
  end
end
