describe FranceTravailApi::UpdateParticipation, type: :service do
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
      "ft-jeton-usager" => "jeton-usager"
    }
  end

  before do
    allow(FranceTravailClient).to receive(:update_participation)
      .and_return(OpenStruct.new(success?: true))
    allow(FranceTravailApi::BuildUserAuthenticatedHeaders).to receive(:call)
      .and_return(OpenStruct.new(headers: headers, success?: true))
  end

  it "sends update request to France Travail API" do
    subject
    expect(FranceTravailClient).to have_received(:update_participation)
  end

  context "when API call fails" do
    before do
      allow(FranceTravailClient).to receive(:update_participation)
        .and_return(OpenStruct.new(success?: false, status: 400, body: "Error"))
    end

    it("is a failure") { is_a_failure }

    it "returns the error" do
      expect(subject.errors).to eq(
        [
          "Impossible d'appeler l'endpoint de l'api rendez-vous-partenaire FT (Update de Participation)." \
          "\nStatus: 400\n Body: Error"
        ]
      )
    end
  end
end
