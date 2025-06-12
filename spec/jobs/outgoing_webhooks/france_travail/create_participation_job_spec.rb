describe OutgoingWebhooks::FranceTravail::CreateParticipationJob do
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
      let!(:participation) { build(:participation, rdv: rdv, user: user, organisation: organisation) }

      context "when user has a valid nir" do
        let!(:user) { create(:user, :with_valid_nir) }

        context "on creation" do
          it "notifies the creation" do
            expect(described_class).to receive(:perform_later)
            participation.save
          end
        end
      end

      context "when user has no nir" do
        let!(:user) { create(:user) }

        context "on creation" do
          it "does not send webhook" do
            expect(described_class).not_to receive(:perform_later)
            participation.save
          end
        end
      end
    end

    context "when organisation is not eligible for France Travail webhooks" do
      let!(:organisation) { create(:organisation, organisation_type: "france_travail", department: department) }
      let!(:user) { create(:user, :with_valid_nir) }
      let!(:rdv) { build(:rdv) }
      let!(:participation) { build(:participation, rdv: rdv, user: user, organisation: organisation) }

      context "on creation" do
        it "does not send webhook" do
          expect(described_class).not_to receive(:perform_later)
          participation.save
        end
      end
    end

    context "when the department is not eligible for France Travail webhooks" do
      let!(:department) { create(:department, disable_ft_webhooks: true) }
      let!(:organisation) { create(:organisation, organisation_type: "delegataire_rsa", department: department) }
      let!(:user) { create(:user, :with_valid_nir) }
      let!(:rdv) { build(:rdv) }
      let!(:participation) { build(:participation, rdv: rdv, user: user, organisation: organisation) }

      context "on creation" do
        it "does not send webhook" do
          expect(described_class).not_to receive(:perform_later)
          participation.save
        end
      end
    end
  end

  describe "#perform" do
    let(:service) { instance_double(FranceTravailApi::CreateParticipation, result: OpenStruct.new) }
    let(:participation) { create(:participation) }
    let(:timestamp) { Time.current }

    before do
      allow(FranceTravailApi::CreateParticipation).to receive(:new).and_return(service)
      allow(service).to receive(:call)
    end

    it "calls the create participation service" do
      described_class.perform_now(
        participation_id: participation.id,
        timestamp: timestamp
      )

      expect(service).to have_received(:call)
    end

    context "when participation is not found (destroyed before the job is processed)" do
      before do
        allow(FranceTravailApi::CreateParticipation).to receive(:new).and_call_original
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
