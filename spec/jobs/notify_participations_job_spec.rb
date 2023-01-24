describe NotifyParticipationsJob do
  subject do
    described_class.new.perform(participation_ids, event_to_notify)
  end

  let!(:rdv_id) { 2213 }
  let!(:event_to_notify) { "created" }
  let!(:rdv) { create(:rdv, id: rdv_id) }
  let!(:participation1) { create(:participation, applicant: applicant1, rdv: rdv) }
  let!(:participation2) { create(:participation, applicant: applicant2, rdv: rdv) }
  let!(:applicant1) { create(:applicant, email: "someone@gmail.com", phone_number: "0607070707") }
  let!(:applicant2) { create(:applicant, email: "anotherone@gmail.com", phone_number: "0606070707") }
  let!(:participation_ids) { [participation1.id, participation2.id] }

  describe "#perform" do
    it "enqueues notification jobs for each applicants and each format" do
      expect(NotifyParticipationJob).to receive(:perform_async)
        .with(participation1.id, "sms", "participation_created")
      expect(NotifyParticipationJob).to receive(:perform_async)
        .with(participation1.id, "email", "participation_created")
      expect(NotifyParticipationJob).to receive(:perform_async)
        .with(participation2.id, "sms", "participation_created")
      expect(NotifyParticipationJob).to receive(:perform_async)
        .with(participation2.id, "email", "participation_created")
      subject
    end

    context "when phone number is not mobile" do
      before { applicant1.update!(phone_number: "0101010101") }

      it "does not enqueue a notification by sms job" do
        expect(NotifyParticipationJob).not_to receive(:perform_async)
          .with(participation1.id, "sms", "participation_created")
        subject
      end
    end

    context "when the phone number is blank" do
      before { applicant1.update!(phone_number: nil) }

      it "does not enqueue a notification by sms job" do
        expect(NotifyParticipationJob).not_to receive(:perform_async)
          .with(participation1.id, "sms", "participation_created")
        subject
      end
    end

    context "when there is no email" do
      before { applicant1.update!(email: nil) }

      it "does not enqueue a notification by email job" do
        expect(NotifyParticipationJob).not_to receive(:perform_async)
          .with(participation1.id, "email", "participation_created")
        subject
      end
    end
  end
end
