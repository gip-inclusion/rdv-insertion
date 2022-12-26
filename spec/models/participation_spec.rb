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

  describe '#destroy' do
    subject { participation1.destroy }

    let!(:rdv) { create(:rdv, participations: [participation1]) }
    let!(:participation1) { create(:participation, applicant: applicant1, rdv_context: rdv_context1) }
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
