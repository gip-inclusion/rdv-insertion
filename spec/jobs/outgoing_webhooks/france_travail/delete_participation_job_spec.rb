describe OutgoingWebhooks::FranceTravail::DeleteParticipationJob do
  let!(:department) { create(:department) }
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
            create(:participation, rdv: rdv, user: user, organisation: organisation, france_travail_id: "123456")
          end

          context "on deletion" do
            it "notifies on deletion" do
              participation_id = participation.id
              france_travail_id = participation.france_travail_id
              user_id = user.id
              expect(described_class).to receive(:perform_later)
                .with(
                  participation_id: participation_id,
                  france_travail_id: france_travail_id,
                  user_id: user_id,
                  timestamp: now
                )
              participation.destroy
            end
          end
        end

        context "when participation has no france_travail_id" do
          let!(:participation) do
            create(:participation, rdv: rdv, user: user, organisation: organisation)
          end

          context "on deletion" do
            it "does not send webhook" do
              expect(described_class).not_to receive(:perform_later)
              participation.destroy
            end
          end
        end
      end

      context "when user has no nir" do
        let!(:user) { create(:user) }
        let!(:rdv) { build(:rdv) }
        let!(:participation) do
          create(:participation, rdv: rdv, user: user, organisation: organisation, france_travail_id: "123456")
        end

        context "on deletion" do
          it "does not send webhook" do
            expect(described_class).not_to receive(:perform_later)
            participation.destroy
          end
        end
      end

      context "when user has a valid France Travail ID" do
        let!(:user) { create(:user, france_travail_id: "12345678901") }
        let!(:rdv) { build(:rdv) }
        let!(:participation) do
          create(:participation, rdv: rdv, user: user, organisation: organisation, france_travail_id: "123456")
        end

        context "on deletion" do
          it "notifies the deletion" do
            expect(described_class).to receive(:perform_later)
            participation.destroy
          end
        end
      end

      context "when user has an invalid France Travail ID" do
        let!(:user) { create(:user, france_travail_id: "12345671") }
        let!(:rdv) { build(:rdv) }
        let!(:participation) do
          create(:participation, rdv: rdv, user: user, organisation: organisation, france_travail_id: "123456")
        end

        context "on deletion" do
          it "does not send webhook" do
            expect(described_class).not_to receive(:perform_later)
            participation.destroy
          end
        end
      end
    end

    context "when organisation is not eligible for France Travail webhooks" do
      let!(:organisation) { create(:organisation, organisation_type: "siae", department: department) }
      let!(:user) { create(:user, :with_valid_nir) }
      let!(:rdv) { build(:rdv) }
      let!(:participation) do
        create(:participation, rdv: rdv, user: user, organisation: organisation)
      end

      context "on deletion" do
        it "does not send webhook on deletion" do
          expect(described_class).not_to receive(:perform_later)
          participation.destroy
        end
      end
    end
  end

  describe "#perform" do
    let(:service) { instance_double(FranceTravailApi::DeleteParticipation, result: OpenStruct.new) }
    let(:participation) { create(:participation) }
    let(:timestamp) { Time.current }

    before do
      allow(FranceTravailApi::DeleteParticipation).to receive(:new).and_return(service)
      allow(service).to receive(:call)
    end

    it "calls the delete participation service" do
      described_class.perform_now(
        participation_id: participation.id,
        france_travail_id: participation.france_travail_id,
        user_id: participation.user_id,
        timestamp: timestamp
      )

      expect(service).to have_received(:call)
    end
  end
end
