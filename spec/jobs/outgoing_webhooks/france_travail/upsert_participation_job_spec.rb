describe OutgoingWebhooks::FranceTravail::UpsertParticipationJob do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, organisation_type: "delegataire_rsa", department: department) }
  let!(:now) { Time.zone.parse("21/01/2023 23:42:11") }

  before do
    travel_to now
    allow(described_class).to receive(:perform_later)
  end

  describe "callbacks" do
    context "when the organisation is eligible for France Travail webhooks" do
      let!(:rdv) { build(:rdv) }

      context "when user has a valid nir" do
        let!(:user) { create(:user, :with_valid_nir) }
        let!(:participation) { build(:participation, rdv: rdv, user: user, organisation: organisation) }

        it "notifies via upsert job on creation" do
          expect(described_class).to receive(:perform_later)
          participation.save
        end

        context "on update" do
          let!(:participation) { create(:participation, rdv: rdv, user: user, organisation: organisation) }

          it "notifies via upsert job on update" do
            expect(described_class).to receive(:perform_later)
            participation.save
          end
        end
      end

      context "when user has a valid France Travail ID" do
        let!(:user) { create(:user, france_travail_id: "12345678901") }
        let!(:participation) { build(:participation, rdv: rdv, user: user, organisation: organisation) }

        it "notifies via upsert job" do
          expect(described_class).to receive(:perform_later)
          participation.save
        end
      end

      context "when user is not eligible" do
        let!(:user) { create(:user, france_travail_id: "12345671") } # ID invalide
        let!(:participation) { build(:participation, rdv: rdv, user: user, organisation: organisation) }

        it "does not send webhook" do
          expect(described_class).not_to receive(:perform_later)
          participation.save
        end
      end
    end

    context "when organisation is not eligible (france_travail type)" do
      let!(:organisation) { create(:organisation, organisation_type: "france_travail", department: department) }
      let!(:user) { create(:user, :with_valid_nir) }
      let!(:rdv) { build(:rdv) }
      let!(:participation) { build(:participation, rdv: rdv, user: user, organisation: organisation) }

      it "does not send webhook" do
        expect(described_class).not_to receive(:perform_later)
        participation.save
      end
    end

    context "when department has webhooks disabled" do
      let!(:department) { create(:department, disable_ft_webhooks: true) }
      let!(:organisation) { create(:organisation, organisation_type: "delegataire_rsa", department: department) }
      let!(:user) { create(:user, :with_valid_nir) }
      let!(:rdv) { build(:rdv) }
      let!(:participation) { build(:participation, rdv: rdv, user: user, organisation: organisation) }

      it "does not send webhook" do
        expect(described_class).not_to receive(:perform_later)
        participation.save
      end
    end
  end

  describe "#perform" do
    let(:create_service) { instance_double(FranceTravailApi::CreateParticipation, result: service_result) }
    let(:update_service) { instance_double(FranceTravailApi::UpdateParticipation, result: service_result) }
    let(:service_result) { OpenStruct.new(errors: []) }
    let(:timestamp) { Time.current }

    context "when participation has no france_travail_id" do
      let(:participation) { create(:participation, france_travail_id: nil) }

      before do
        allow(FranceTravailApi::CreateParticipation).to receive(:new).and_return(create_service)
        allow(create_service).to receive(:call)
        allow(FranceTravailApi::UpdateParticipation).to receive(:new).and_return(update_service)
        allow(update_service).to receive(:call)
      end

      it "calls CreateParticipation service only" do
        described_class.perform_now(
          participation_id: participation.id,
          timestamp: timestamp
        )

        expect(create_service).to have_received(:call)
        expect(update_service).not_to have_received(:call)
      end
    end

    context "when participation has a france_travail_id" do
      let(:participation) { create(:participation, france_travail_id: "ft-123") }

      before do
        allow(FranceTravailApi::UpdateParticipation).to receive(:new).and_return(update_service)
        allow(update_service).to receive(:call).and_return(service_result)
        allow(FranceTravailApi::CreateParticipation).to receive(:new).and_return(create_service)
        allow(create_service).to receive(:call)
      end

      it "calls UpdateParticipation service only" do
        described_class.perform_now(
          participation_id: participation.id,
          timestamp: timestamp
        )

        expect(update_service).to have_received(:call)
        expect(create_service).not_to have_received(:call)
      end

      context "when update service fails with regular error" do
        before do
          allow(update_service).to receive(:call)
            .and_raise(ApplicationJob::FailedServiceError, "Some error")
        end

        it "raises a FailedServiceError" do
          expect do
            described_class.perform_now(
              participation_id: participation.id,
              timestamp: timestamp
            )
          end.to raise_error(ApplicationJob::FailedServiceError)
        end
      end

      context "when update service fails with NoMatchingUser error" do
        before do
          allow(update_service).to receive(:call)
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
    end

    context "when participation is not found" do
      before do
        allow(FranceTravailApi::CreateParticipation).to receive(:new).and_call_original
        allow(FranceTravailApi::UpdateParticipation).to receive(:new).and_call_original
      end

      it "discards the job without raising an error" do
        expect do
          perform_enqueued_jobs do
            described_class.perform_now(
              participation_id: 999_999,
              timestamp: timestamp
            )
          end
        end.not_to raise_error

        assert_no_enqueued_jobs
      end
    end
  end
end
