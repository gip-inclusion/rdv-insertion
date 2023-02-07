describe Participation do
  describe "rdv_solidarites_participation_id uniqueness validation" do
    context "no collision" do
      let(:participation) { build(:participation, rdv_solidarites_participation_id: 1) }

      it { expect(participation).to be_valid }
    end

    context "blank rdv_solidarites_participation_id" do
      let!(:participation_existing) { create(:participation, rdv_solidarites_participation_id: 1) }

      let(:participation) { build(:participation, rdv_solidarites_participation_id: "") }

      it { expect(participation).to be_valid }
    end

    context "colliding rdv_solidarites_participation_id" do
      let!(:participation_existing) { create(:participation, rdv_solidarites_participation_id: 1) }
      let(:participation) { build(:participation, rdv_solidarites_participation_id: 1) }

      it "adds errors" do
        expect(participation).not_to be_valid
        expect(participation.errors.details).to eq({ rdv_solidarites_participation_id: [{ error: :taken, value: 1 }] })
        expect(participation.errors.full_messages.to_sentence)
          .to include("Rdv solidarites participation est déjà utilisé")
      end
    end
  end

  describe "#notify_applicants" do
    subject { participation.save }

    let!(:participation_id) { 333 }
    let!(:rdv) { create(:rdv, convocable: true) }
    let!(:applicant) { create(:applicant) }
    let!(:participation) do
      build(:participation, id: participation_id, rdv: rdv, applicant: applicant, status: "unknown")
    end

    context "after record creation" do
      it "enqueues a job to notify the applicant" do
        expect(NotifyParticipationJob).to receive(:perform_async)
          .with(participation.id, "sms", "participation_created")
        expect(NotifyParticipationJob).to receive(:perform_async)
          .with(participation.id, "email", "participation_created")
        subject
      end

      context "when the rdv is not convocable" do
        let!(:rdv) { create(:rdv, convocable: false) }

        it "does not enqueue a notify applicants job" do
          expect(NotifyParticipationJob).not_to receive(:perform_async)
          subject
        end
      end

      context "when the applicant has no email" do
        let!(:applicant) { create(:applicant, email: nil) }

        it "enqueues a job to notify by sms only" do
          expect(NotifyParticipationJob).to receive(:perform_async)
            .with(participation_id, "sms", "participation_created")
          expect(NotifyParticipationJob).not_to receive(:perform_async)
            .with(participation_id, "email", "participation_created")
          subject
        end
      end

      context "when the applicant has no phone" do
        let!(:applicant) { create(:applicant, phone_number: nil) }

        it "enqueues a job to notify by sms only" do
          expect(NotifyParticipationJob).not_to receive(:perform_async)
            .with(participation_id, "sms", "participation_created")
          expect(NotifyParticipationJob).to receive(:perform_async)
            .with(participation_id, "email", "participation_created")
          subject
        end
      end
    end

    context "after cancellation" do
      let!(:participation) do
        create(
          :participation,
          rdv: rdv,
          applicant: applicant,
          status: "unknown"
        )
      end

      it "enqueues a job to notify rdv applicants" do
        participation.status = "excused"
        expect(NotifyParticipationJob).to receive(:perform_async)
          .with(participation.id, "sms", "participation_cancelled")
        expect(NotifyParticipationJob).to receive(:perform_async)
          .with(participation.id, "email", "participation_cancelled")
        subject
      end

      context "when the rdv is not convocable" do
        let!(:rdv) { create(:rdv, convocable: false) }

        it "does not enqueue a notify applicants job" do
          expect(NotifyParticipationJob).not_to receive(:perform_async)
          subject
        end
      end

      context "when the participation is already cancelled" do
        let!(:participation) do
          create(
            :participation,
            rdv: rdv,
            applicant: applicant,
            status: "excused"
          )
        end

        it "does not enqueue a notify applicants job" do
          participation.status = "excused"
          expect(NotifyParticipationJob).not_to receive(:perform_async)
          subject
        end
      end
    end
  end

  describe "#destroy" do
    subject { participation1.destroy }

    let!(:participation1) { create(:participation, applicant: applicant1, rdv_context: rdv_context1) }
    let!(:applicant1) { create(:applicant, rdv_contexts: [rdv_context1, rdv_context2]) }
    let!(:rdv_context1) { create(:rdv_context, motif_category: create(:motif_category), status: "rdv_seen") }
    let!(:rdv_context2) { create(:rdv_context, motif_category: create(:motif_category), status: "rdv_seen") }

    it "schedules a refresh_applicant_context_statuses job" do
      expect { subject }.to change { RefreshRdvContextStatusesJob.jobs.size }.by(1)
      last_job = RefreshRdvContextStatusesJob.jobs.last
      expect(last_job["args"]).to eq([rdv_context1.id])
    end
  end
end
