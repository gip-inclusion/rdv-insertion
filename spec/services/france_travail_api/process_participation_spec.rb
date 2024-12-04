describe FranceTravailApi::ProcessParticipation, type: :service do
  subject do
    described_class.call(participation_id: participation.id, timestamp: timestamp, event: event)
  end

  describe "#call" do
    let(:participation) { create(:participation) }
    let(:timestamp) { Time.current }
    let(:event) { :create }
    let(:headers) do
      { "Authorization" => "Bearer token", "Content-Type" => "application/json", "Accept" => "application/json",
        "ft-jeton-usager" => "jeton-usager" }
    end

    before do
      allow(FranceTravailClient).to receive_messages(
        create_participation: OpenStruct.new(success?: true, body: { id: "ft-123" }.to_json),
        update_participation: OpenStruct.new(success?: true),
        delete_participation: OpenStruct.new(success?: true)
      )
      allow(FranceTravailApi::BuildUserAuthenticatedHeaders).to receive(:call)
        .and_return(OpenStruct.new(headers: headers, success?: true))
    end

    context "when creating a participation" do
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
              "Impossible d'appeler l'endpoint de l'api rendez-vous-partenaire FT (Endpoint : create)." \
              "\nStatus: 400\n Body: Error"
            ]
          )
        end
      end
    end

    context "when updating a participation" do
      let(:event) { :update }

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
              "Impossible d'appeler l'endpoint de l'api rendez-vous-partenaire FT (Endpoint : update)." \
              "\nStatus: 400\n Body: Error"
            ]
          )
        end
      end
    end

    context "when deleting a participation" do
      let(:event) { :delete }

      it "sends delete request to France Travail API" do
        subject
        expect(FranceTravailClient).to have_received(:delete_participation)
      end

      context "when API call fails" do
        before do
          allow(FranceTravailClient).to receive(:delete_participation)
            .and_return(OpenStruct.new(success?: false, status: 400, body: "Error"))
        end

        it("is a failure") { is_a_failure }

        it "returns the error" do
          expect(subject.errors).to eq(
            [
              "Impossible d'appeler l'endpoint de l'api rendez-vous-partenaire FT (Endpoint : delete)." \
              "\nStatus: 400\n Body: Error"
            ]
          )
        end
      end
    end
  end
end
