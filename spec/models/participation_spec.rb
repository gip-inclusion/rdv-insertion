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

    let!(:rdv_id) { 333 }
    let!(:rdv) { create(:rdv, id: rdv_id, convocable: true) }
    let!(:applicant) { create(:applicant) }
    let!(:participation) { build(:participation, rdv_id: rdv_id, applicant_id: applicant.id, status: "unknown") }

    context "after record creation" do
      it "enqueues a job to notify rdv applicants" do
        expect(NotifyRdvToApplicantJob).to receive(:perform_async)
          .with(rdv_id, applicant.id, "sms", 'rdv_created')
        expect(NotifyRdvToApplicantJob).to receive(:perform_async)
          .with(rdv_id, applicant.id, "email", 'rdv_created')
        subject
      end

      context "when the rdv is not convocable" do
        let!(:rdv) { create(:rdv, id: rdv_id, convocable: false) }

        it "does not enqueue a notify applicants job" do
          expect(NotifyRdvToApplicantJob).not_to receive(:perform_async)
          subject
        end
      end
    end

    context "after cancellation" do
      let!(:participation) do
        create(
          :participation,
          rdv_id: rdv_id,
          applicant_id: applicant.id,
          status: "unknown"
        )
      end

      it "enqueues a job to notify rdv applicants" do
        participation.status = "excused"
        participation.cancelled_at = Time.zone.now
        expect(NotifyRdvToApplicantJob).to receive(:perform_async)
          .with(rdv_id, applicant.id, "sms", 'rdv_cancelled')
        expect(NotifyRdvToApplicantJob).to receive(:perform_async)
          .with(rdv_id, applicant.id, "email", 'rdv_cancelled')
        subject
      end

      context "when the rdv is not convocable" do
        let!(:rdv) { create(:rdv, id: rdv_id, convocable: false) }

        it "does not enqueue a notify applicants job" do
          rdv.cancelled_at = Time.zone.now
          expect(NotifyRdvToApplicantsJob).not_to receive(:perform_async)
          subject
        end
      end
    end
  end

  describe '#destroy' do
    subject { participation1.destroy }

    let!(:rdv) { create(:rdv, rdv_contexts: [rdv_context1, rdv_context2]) }
    let!(:participation1) { create(:participation, rdv: rdv, applicant: applicant1) }
    let!(:applicant1) { create(:applicant, rdv_contexts: [rdv_context1, rdv_context2]) }
    let!(:rdv_context1) { create(:rdv_context, motif_category: "rsa_orientation", status: "rdv_seen") }
    let!(:rdv_context2) { create(:rdv_context, motif_category: "rsa_accompagnement", status: "rdv_seen") }

    it 'schedules a refresh_applicant_context_statuses job' do
      expect { subject }.to change { RefreshRdvContextStatusesJob.jobs.size }.by(1)
      last_job = RefreshRdvContextStatusesJob.jobs.last
      expect(last_job['args']).to eq([applicant1.rdv_contexts.map(&:id)])
    end
  end
end
