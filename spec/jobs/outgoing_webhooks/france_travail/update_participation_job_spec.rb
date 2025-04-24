describe OutgoingWebhooks::FranceTravail::UpdateParticipationJob do
  let!(:department) { create(:department, :ft_department) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:now) { Time.zone.parse("21/01/2023 23:42:11") }

  before do
    travel_to now
    allow(described_class).to receive(:perform_later)
  end

  describe "callbacks" do
    context "when the organisation is eligible for France Travail webhooks" do
      context "when user has a valid nir" do
        let!(:user) { create(:user, :with_valid_nir) }
        let!(:rdv) { build(:rdv) }

        context "when participation has a france_travail_id" do
          let!(:participation) do
            create(:participation, rdv: rdv, user: user, organisation: organisation, france_travail_id: "12345")
          end

          context "on update" do
            it "notifies on update" do
              expect(described_class).to receive(:perform_later)
                .with(
                  participation_id: participation.id,
                  timestamp: participation.updated_at
                )
              participation.save
            end
          end
        end

        context "when participation has no france_travail_id" do
          let!(:participation) do
            create(:participation, rdv: rdv, user: user, organisation: organisation)
          end

          context "on update" do
            it "does not send webhook" do
              expect(described_class).not_to receive(:perform_later)
              participation.save
            end
          end
        end
      end

      context "when user has no nir" do
        let!(:user) { create(:user) }
        let!(:rdv) { build(:rdv) }
        let!(:participation) { build(:participation, rdv: rdv, user: user, organisation: organisation) }

        context "on update" do
          it "does not send webhook" do
            expect(described_class).not_to receive(:perform_later)
            participation.save
          end
        end
      end
    end

    context "when organisation is not eligible for France Travail webhooks" do
      let!(:organisation) { create(:organisation, organisation_type: "autre", department: department) }
      let!(:user) { create(:user, :with_valid_nir) }
      let!(:rdv) { build(:rdv) }
      let!(:participation) do
        create(:participation, rdv: rdv, user: user, organisation: organisation)
      end

      context "on update" do
        it "does not send webhook" do
          expect(described_class).not_to receive(:perform_later)
          participation.save
        end
      end
    end
  end

  describe "#perform" do
    let(:service) { instance_double(FranceTravailApi::UpdateParticipation, result: service_result) }
    let(:participation) { create(:participation) }
    let(:timestamp) { Time.current }
    let(:service_result) { OpenStruct.new(errors: []) }

    before do
      allow(FranceTravailApi::UpdateParticipation).to receive(:new).and_return(service)
      allow(service).to receive(:call).and_return(service_result)
    end

    context "when service succeeds" do
      it "calls the update participation service" do
        described_class.perform_now(
          participation_id: participation.id,
          timestamp: timestamp
        )

        expect(service).to have_received(:call)
      end
    end

    context "when service fails with regular error" do
      before do
        allow(service).to receive(:call)
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

    context "when service fails with NoMatchingUser error" do
      before do
        allow(service).to receive(:call)
          .and_raise(FranceTravailApi::RetrieveUserToken::NoMatchingUser, "Aucun usager trouvé")
      end

      it "discards the job without raising an error" do
        expect do
          perform_enqueued_jobs do
            described_class.perform_now(
              participation_id: participation.id,
              timestamp: timestamp
            )
          end
        end.not_to raise_error # Le job est discard quand il y a une erreur NoMatchingUser

        assert_no_enqueued_jobs
      end
    end
  end
end
