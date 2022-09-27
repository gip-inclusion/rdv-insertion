describe Applicants::Archive, type: :service do
  subject do
    described_class.call(
      rdv_solidarites_session: rdv_solidarites_session,
      applicant: applicant, archiving_reason: archiving_reason
    )
  end

  let!(:applicant) { create(:applicant) }
  let(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }
  let!(:archiving_reason) { "some reason" }
  let!(:archived_at) { Time.zone.now }
  let!(:invitation1) { create(:invitation, applicant: applicant) }
  let!(:invitation2) { create(:invitation, applicant: applicant) }

  describe "#call" do
    before do
      allow(InvalidateInvitationJob).to receive(:perform_async)
    end

    it "is a success" do
      expect(subject.success?).to eq(true)
    end

    it "change the archived_at value" do
      subject
      expect(applicant.reload.archived_at.to_date).to eq(archived_at.to_date)
    end

    it "saves the archiving_reason" do
      subject
      expect(applicant.reload.archiving_reason).to eq(archiving_reason)
    end

    it "calls the InvalidateInvitationJob for the applicants invitations" do
      expect(InvalidateInvitationJob).to receive(:perform_async).exactly(1).time.with(invitation1.id)
      expect(InvalidateInvitationJob).to receive(:perform_async).exactly(1).time.with(invitation2.id)
      subject
    end

    context "when the applicant cannot be updated" do
      before do
        allow(applicant).to receive(:save)
          .and_return(false)
        allow(applicant).to receive_message_chain(:errors, :full_messages, :to_sentence)
          .and_return('some error')
      end

      it "is a failure" do
        expect(subject.success?).to eq(false)
      end

      it "stores the error" do
        expect(subject.errors).to eq(['some error'])
      end

      it "does not call the InvalidateInvitationJob" do
        expect(InvalidateInvitationJob).not_to receive(:perform_async)
        subject
      end
    end
  end
end
