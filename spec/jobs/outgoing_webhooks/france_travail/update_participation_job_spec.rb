describe OutgoingWebhooks::FranceTravail::UpdateParticipationJob do
  let!(:organisation) { create(:organisation, safir_code: "123456") }
  let!(:now) { Time.zone.parse("21/01/2023 23:42:11") }

  before do
    travel_to now
    allow(described_class).to receive(:perform_later)
  end

  describe "callbacks" do
    context "when the organisation is france_travail and user is valid" do
      let!(:user) { create(:user, :with_valid_nir) }
      let!(:rdv) { build(:rdv) }

      context "on update" do
        let!(:participation) do
          create(:participation, rdv: rdv, user: user, organisation: organisation, france_travail_id: "12345")
        end

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

    context "when organisation is not france_travail" do
      let!(:organisation) { create(:organisation, safir_code: nil) }

      context "on update" do
        let!(:participation) { create(:participation, organisation: organisation) }

        it "does not send webhook" do
          expect(described_class).not_to receive(:perform_later)
          participation.save
        end
      end
    end

    context "when organisation is france_travail but user has no nir" do
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

  describe "#perform" do
    let(:service) { instance_double(FranceTravailApi::UpdateParticipation, result: service_result) }
    let(:participation) { create(:participation) }
    let(:timestamp) { Time.current }
    let(:service_result) { OpenStruct.new(errors: [], non_retryable_error: false) }

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

    context "when service fails with retryable error" do
      let(:service_result) { OpenStruct.new(errors: ["Some error"], non_retryable_error: false) }

      before do
        allow(service).to receive(:call).and_return(service_result)
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

    context "when service fails with non retryable error" do
      let(:service_result) { OpenStruct.new(errors: ["User not found"], non_retryable_error: true) }

      before do
        allow(service).to receive(:call).and_return(service_result)
      end

      it "discards the job without raising an error" do
        expect do
          described_class.perform_now(
            participation_id: participation.id,
            timestamp: timestamp
          )
        end.not_to raise_error
        expect(Sidekiq::RetrySet.new.size).to eq(0)
      end
    end
  end
end
