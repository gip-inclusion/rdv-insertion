describe Rdv do
  describe "rdv rdv_solidarites_rdv_id uniqueness validation" do
    context "no collision" do
      let(:rdv) { build(:rdv, rdv_solidarites_rdv_id: 1) }

      it { expect(rdv).to be_valid }
    end

    context "blank rdv_solidarites_rdv_id" do
      let(:rdv) { build(:rdv, rdv_solidarites_rdv_id: "") }

      it "adds errors" do
        expect(rdv).not_to be_valid
        expect(rdv.errors.details).to eq({ rdv_solidarites_rdv_id: [{ error: :blank }] })
        expect(rdv.errors.full_messages.to_sentence)
          .to include("Rdv solidarites rdv doit être rempli(e)")
      end
    end

    context "colliding rdv_solidarites_rdv_id" do
      let!(:rdv_existing) { create(:rdv, rdv_solidarites_rdv_id: 1) }
      let(:rdv) { build(:rdv, rdv_solidarites_rdv_id: 1) }

      it "adds errors" do
        expect(rdv).not_to be_valid
        expect(rdv.errors.details).to eq({ rdv_solidarites_rdv_id: [{ error: :taken, value: 1 }] })
        expect(rdv.errors.full_messages.to_sentence)
          .to include("Rdv solidarites rdv est déjà utilisé")
      end
    end
  end

  describe "#notify_applicants" do
    subject { rdv.save }

    let!(:participation) { create(:participation, convocable: true) }

    context "when the lieu is updated" do
      let!(:rdv) { create(:rdv, participations: [participation], address: "some place") }

      it "enqueues a job to notify rdv applicants" do
        rdv.address = "some other place"
        expect(NotifyParticipationsJob).to receive(:perform_async)
          .with([participation.id], :updated)
        subject
      end

      context "when the rdv is not convocable" do
        before { participation.update! convocable: false }

        it "does not enqueue a notify applicants job" do
          rdv.address = "some other place"
          expect(NotifyParticipationsJob).not_to receive(:perform_async)
          subject
        end
      end
    end

    context "when the start time is updated" do
      let!(:rdv) { create(:rdv, participations: [participation], starts_at: 2.days.from_now) }

      it "enqueues a job to notify rdv applicants" do
        rdv.starts_at = 3.days.from_now
        expect(NotifyParticipationsJob).to receive(:perform_async)
          .with([participation.id], :updated)
        subject
      end

      context "when the rdv is not convocable" do
        before { participation.update! convocable: false }

        it "does not enqueue a notify applicants job" do
          rdv.starts_at = 3.days.from_now
          expect(NotifyParticipationsJob).not_to receive(:perform_async)
          subject
        end
      end
    end

    context "when the another attribute is updated" do
      let!(:rdv) { create(:rdv, participations: [participation], duration_in_min: 30) }

      it "does not enqueue a notify applicants job" do
        rdv.duration_in_min = 45
        expect(NotifyParticipationJob).not_to receive(:perform_async)
        subject
      end
    end
  end
end
