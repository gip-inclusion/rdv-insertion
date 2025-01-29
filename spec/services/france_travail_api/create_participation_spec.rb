describe FranceTravailApi::CreateParticipation, type: :service do
  subject do
    described_class.call(participation_id: participation.id, timestamp: timestamp)
  end

  let(:participation) { create(:participation) }
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
    allow(FranceTravailClient).to receive(:create_participation)
      .and_return(OpenStruct.new(success?: true, body: { id: "ft-123" }.to_json))
    allow(FranceTravailApi::BuildUserAuthenticatedHeaders).to receive(:call)
      .and_return(OpenStruct.new(headers: headers, success?: true))
  end

  it "sends creation request to France Travail API" do
    subject
    expect(FranceTravailClient).to have_received(:create_participation)
  end

  it "updates participation with France Travail ID" do
    subject
    expect(participation.reload.france_travail_id).to eq("ft-123")
  end

  context "when API call fails" do
    before do
      allow(FranceTravailClient).to receive(:create_participation)
        .and_return(OpenStruct.new(success?: false, status: 400, body: "Error"))
    end

    it("is a failure") { is_a_failure }

    it "returns the error" do
      expect(subject.errors).to eq(
        [
          "Impossible d'appeler l'endpoint de l'api rendez-vous-partenaire FT (Création de Participation)." \
          "\nStatus: 400\n Body: Error"
        ]
      )
    end
  end
end
