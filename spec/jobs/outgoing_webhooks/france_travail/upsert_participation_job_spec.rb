describe OutgoingWebhooks::FranceTravail::UpsertParticipationJob do
  subject { described_class.perform_now(participation_id: participation.id, timestamp: timestamp) }

  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, organisation_type: "delegataire_rsa", department: department) }
  let!(:timestamp) { Time.zone.parse("21/01/2023 23:42:11") }
  let!(:participation) { create(:participation, france_travail_id: nil) }

  before do
    travel_to timestamp
    allow(FranceTravailApi::CreateParticipation).to receive(:call)
      .and_return(OpenStruct.new(success?: true, errors: []))
    allow(FranceTravailApi::UpdateParticipation).to receive(:call)
      .and_return(OpenStruct.new(success?: true, errors: []))
    allow_any_instance_of(Participation).to receive(:eligible_for_france_travail_webhook?).and_return(true)
  end

  describe "#perform" do
    context "when participation has no france_travail_id" do
      it "calls CreateParticipation service only" do
        subject

        expect(FranceTravailApi::CreateParticipation).to have_received(:call)
        expect(FranceTravailApi::UpdateParticipation).not_to have_received(:call)
      end
    end

    context "when participation has a france_travail_id" do
      let(:participation) { create(:participation, france_travail_id: "ft-123") }

      it "calls UpdateParticipation service only" do
        subject

        expect(FranceTravailApi::UpdateParticipation).to have_received(:call)
        expect(FranceTravailApi::CreateParticipation).not_to have_received(:call)
      end

      context "when update service fails with regular error" do
        before do
          allow(FranceTravailApi::UpdateParticipation).to receive(:call)
            .and_raise(ApplicationJob::FailedServiceError, "Some error")
        end

        it "raises a FailedServiceError" do
          expect do
            subject
          end.to raise_error(ApplicationJob::FailedServiceError)
        end
      end

      context "when update service fails with NoMatchingUser error" do
        before do
          allow(FranceTravailApi::UpdateParticipation).to receive(:call)
            .and_raise(FranceTravailApi::RetrieveUserToken::NoMatchingUser, "Aucun usager trouvé")
        end

        it "discards the job without raising an error" do
          expect do
            described_class.perform_now(
              participation_id: participation.id,
              timestamp: timestamp
            )
          end.not_to raise_error
        end
      end

      context "when update service fails with AccessForbidden error" do
        before do
          allow(FranceTravailApi::UpdateParticipation).to receive(:call)
            .and_raise(FranceTravailApi::RetrieveUserToken::AccessForbidden, "Aucun usager trouvé")
        end

        it "discards the job without raising an error" do
          expect do
            described_class.perform_now(
              participation_id: participation.id,
              timestamp: timestamp
            )
          end.not_to raise_error
        end
      end

      context "when update service fails with ParticipationNotFound error" do
        before do
          allow(FranceTravailApi::UpdateParticipation).to receive(:call)
            .and_raise(FranceTravailApi::UpdateParticipation::ParticipationNotFound,
                       "L'ID France Travail de la participation n'existe plus")
        end

        it "clears the france_travail_id and calls CreateParticipation" do
          subject

          expect(participation.reload.france_travail_id).to be_nil
          expect(FranceTravailApi::CreateParticipation).to have_received(:call)
            .with(participation: participation, timestamp: timestamp)
        end

        it "does not raise an error" do
          expect { subject }.not_to raise_error
        end
      end
    end

    context "when participation is not found" do
      it "discards the job without raising an error" do
        described_class.perform_now(
          participation_id: 999_999,
          timestamp: timestamp
        )

        expect(FranceTravailApi::UpdateParticipation).not_to have_received(:call)
        expect(FranceTravailApi::CreateParticipation).not_to have_received(:call)
      end
    end

    context "when participation is not eligible to ft webhooks" do
      before do
        allow_any_instance_of(Participation).to receive(:eligible_for_france_travail_webhook?).and_return(false)
      end

      it "discards the job without raising an error" do
        subject

        expect(FranceTravailApi::UpdateParticipation).not_to have_received(:call)
        expect(FranceTravailApi::CreateParticipation).not_to have_received(:call)
      end
    end
  end
end
