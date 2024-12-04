describe OutgoingWebhooks::FranceTravail::CreateParticipationJob do
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

      context "on creation" do
        let!(:participation) { build(:participation, rdv: rdv, user: user, organisation: organisation) }

        it "notifies the creation" do
          expect(described_class).to receive(:perform_later)
          participation.save
        end
      end
    end

    context "when organisation is not france_travail" do
      let!(:organisation) { create(:organisation, safir_code: nil) }

      context "on creation" do
        let!(:participation) { build(:participation, organisation: organisation) }

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
  end
end
