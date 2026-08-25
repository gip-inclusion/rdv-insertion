describe FranceTravailApi::CancelParticipation, type: :service do
  subject do
    described_class.call(
      participation_id: participation.id,
      france_travail_id: france_travail_id,
      user: user,
      timestamp: timestamp
    )
  end

  let!(:user) { create(:user, :with_valid_nir) }
  let!(:rdv) { create(:rdv) }
  let!(:participation) { create(:participation, rdv: rdv, user: user) }
  let(:france_travail_id) { "ft-123" }
  let(:timestamp) { Time.current }
  let(:headers) do
    {
      "Authorization" => "Bearer token",
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "ft-jeton-usager" => "jeton-usager",
      "pa-identifiant-agent" => "BATCH",
      "pa-nom-agent" => "Webhooks Participation RDV-Insertion",
      "pa-prenom-agent" => "Webhooks Participation RDV-Insertion"
    }
  end

  before do
    allow(FranceTravailClient).to receive(:cancel_participation)
      .and_return(OpenStruct.new(success?: true))
    allow(FranceTravailApi::BuildUserAuthenticatedHeaders).to receive(:call)
      .and_return(OpenStruct.new(headers: headers, success?: true))
  end

  it "sends delete request to France Travail API" do
    subject
    expect(FranceTravailClient).to have_received(:cancel_participation)
  end

  context "when API call fails" do
    before do
      allow(FranceTravailClient).to receive(:cancel_participation)
        .and_return(OpenStruct.new(success?: false, status: 400, body: "Error"))
    end

    it("is a failure") { is_a_failure }

    it "returns the error" do
      expect(subject.errors).to eq(
        [
          "Impossible d'appeler l'endpoint de l'api rendez-vous-partenaire FT (Suppression de Participation)." \
          "\nStatus: 400\n Body: Error"
        ]
      )
    end
  end

  context "when API call fails with ID_NON_RECONNU error" do
    let(:error_body) do
      {
        codeHttp: 400,
        codeErreur: "ID_NON_RECONNU",
        message: "Il n'existe pas de rdv pour l'id et l'utilisateur indiqué"
      }.to_json
    end

    before do
      allow(FranceTravailClient).to receive(:cancel_participation)
        .and_return(OpenStruct.new(success?: false, status: 400, body: error_body))
    end

    it("is a failure") { is_a_failure }

    it "sets error_type to :participation_not_found" do
      expect(subject.error_type).to eq(:participation_not_found)
    end
  end
end
