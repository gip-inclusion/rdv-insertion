describe Orientations::Save, type: :service do
  subject do
    described_class.call(orientation:)
  end

  let!(:user) { create(:user) }
  let!(:orientation) { build(:orientation, user:, starts_at:, ends_at:, organisation:) }

  let(:organisation) { create(:organisation) }

  let!(:starts_at) { Date.parse("12/12/2022") }
  let!(:ends_at) { Date.parse("22/12/2022") }

  before do
    allow(Users::AddToOrganisations).to receive(:call)
      .with(user: user, organisations: [organisation])
      .and_return(OpenStruct.new(success?: true))
  end

  describe "#call" do
    it "is a success" do
      is_a_success
    end

    it "saves the orientation" do
      subject
      expect(orientation.persisted?).to eq(true)
    end

    context "when starts_at is not passed" do
      let!(:starts_at) { nil }

      it "is a failure" do
        is_a_failure
      end

      it "outputs the error" do
        expect(subject.errors).to eq(["Une date de début doit être indiquée"])
      end
    end

    context "when the user has multiple orientations already" do
      let!(:first_orientation) do
        create(:orientation, user:, starts_at: Date.parse("09/10/2022"), ends_at: Date.parse("09/11/2022"))
      end
      let!(:second_orientation) do
        create(:orientation, user:, starts_at: Date.parse("11/11/2022"), ends_at: nil)
      end

      context "when the previous orientation does not have an end date" do
        context "without overlap override" do
          it "is a failure" do
            is_a_failure
          end

          it "outputs an error" do
            expect(subject.shrinkeable_orientation).not_to be_nil
          end
        end

        context "when we force overlap override" do
          subject do
            described_class.call(orientation:, update_anterior_ends_at: true)
          end

          it "is a success" do
            is_a_success
          end

          it "saves the orientation" do
            subject
            expect(orientation.persisted?).to eq(true)
          end

          it "sets the ends_at of the last orientation" do
            subject
            expect(second_orientation.reload.ends_at).to eq(starts_at - 1.day)
          end
        end
      end

      context "when the previous orientation end date overlaps" do
        let!(:second_orientation) do
          create(:orientation, user:, starts_at: Date.parse("11/11/2022"), ends_at: Date.parse("24/11/2022"))
        end

        let!(:starts_at) { Date.parse("22/11/2022") }
        let!(:ends_at) { Date.parse("30/12/2022") }

        context "without overlap override" do
          it "is a failure" do
            is_a_failure
          end

          it "outputs an error" do
            expect(subject.shrinkeable_orientation).not_to be_nil
          end
        end

        context "when we force overlap override" do
          subject do
            described_class.call(orientation:, update_anterior_ends_at: true)
          end

          it "is a success" do
            is_a_success
          end

          it "saves the orientation" do
            subject
            expect(orientation.persisted?).to eq(true)
          end

          it "sets the ends_at of the last orientation" do
            subject
            expect(second_orientation.reload.ends_at).to eq(starts_at - 1.day)
          end
        end
      end

      context "when the current orientation does not have an end date" do
        let!(:ends_at) { nil }

        context "when it starts after all the other orientations" do
          subject do
            described_class.call(orientation:, update_anterior_ends_at: true)
          end

          it "stays at nil and set the previous ends_at" do
            subject
            is_a_success
            expect(orientation.reload.ends_at).to be_nil
          end
        end

        context "when it is before the other orientations" do
          let!(:starts_at) { Date.parse("07/07/2022") }

          it "sets the ends_at one day before the posterior starts_at" do
            subject
            is_a_success
            expect(orientation.reload.ends_at).to eq(Date.parse("08/10/2022"))
            expect(second_orientation.reload.ends_at).to be_nil
          end
        end

        context "when it is conflicting with an other orientation" do
          let!(:starts_at) { Date.parse("11/10/2022") }

          it "is a failure" do
            is_a_failure
          end

          it "outputs an error" do
            expect(subject.errors.first).to include("Cette orientation chevauche une autre orientation")
          end
        end

        context "when it is between two orientations" do
          let!(:starts_at) { Date.parse("10/11/2022") }

          let!(:second_orientation) do
            create(:orientation, user:, starts_at: Date.parse("21/11/2022"), ends_at: nil)
          end

          it "sets the ends_at at the posterior starts_at" do
            subject
            is_a_success
            expect(orientation.reload.ends_at).to eq(Date.parse("20/11/2022"))
            expect(second_orientation.reload.ends_at).to be_nil
          end
        end
      end

      context "when the time range includes an other orientation" do
        let!(:starts_at) { Date.parse("10/10/2022") }

        it "is a failure" do
          is_a_failure
        end

        it "outputs an error" do
          expect(subject.errors.first).to include("Cette orientation chevauche une autre orientation")
        end

        it "does not set the previous ends_at" do
          subject
          expect(second_orientation.reload.ends_at).to be_nil
        end
      end

      context "when the starts_at is in another orientation time range" do
        let!(:starts_at) { Date.parse("20/10/2022") }

        it "is a failure" do
          is_a_failure
        end

        it "outputs an error" do
          expect(subject.errors.first).to include("Cette orientation chevauche une autre orientation")
        end

        it "does not set the previous ends_at" do
          subject
          expect(second_orientation.reload.ends_at).to be_nil
        end
      end

      context "when the ends_at is in another orientation time range" do
        let!(:starts_at) { Date.parse("05/10/2022") }
        let!(:ends_at) { Date.parse("20/10/2022") }

        it "is a failure" do
          is_a_failure
        end

        it "outputs an error" do
          expect(subject.errors.first).to include("Cette orientation chevauche une autre orientation")
        end

        it "does not set the previous ends_at" do
          subject
          expect(second_orientation.reload.ends_at).to be_nil
        end
      end

      context "when user is not part of the organisation" do
        it "adds the user to the organisation" do
          expect(Users::AddToOrganisations).to receive(:call)
            .with(user: user, organisations: [organisation])
            .once
            .and_return(OpenStruct.new(success?: true))

          subject
        end
      end

      context "when both starts_at and ends_at are included in another orientation time range" do
        let!(:starts_at) { Date.parse("15/10/2022") }
        let!(:ends_at) { Date.parse("24/10/2022") }

        it "is a failure" do
          is_a_failure
        end

        it "outputs an error" do
          expect(subject.errors.first).to include("Cette orientation chevauche une autre orientation")
        end

        it "does not set the previous ends_at" do
          subject
          expect(second_orientation.reload.ends_at).to be_nil
        end
      end
    end
  end
end
