describe NotifyRdvToApplicantsJob do
  subject do
    described_class.new.perform(rdv_id, event_to_notify)
  end

  let!(:rdv_id) { 2213 }
  let!(:event_to_notify) { "created" }
  let!(:rdv) { create(:rdv, id: rdv_id, applicants: [applicant1, applicant2]) }
  let!(:applicant1) { create(:applicant, email: "someone@gmail.com", phone_number: "0607070707") }
  let!(:applicant2) { create(:applicant, email: "anotherone@gmail.com", phone_number: "0606070707") }

  describe "#perform" do
    it "enqueues notification jobs for each applicants and each format" do
      expect(NotifyRdvToApplicantJob).to receive(:perform_async)
        .with(rdv_id, applicant1.id, "sms", "rdv_created")
      expect(NotifyRdvToApplicantJob).to receive(:perform_async)
        .with(rdv_id, applicant1.id, "email", "rdv_created")
      expect(NotifyRdvToApplicantJob).to receive(:perform_async)
        .with(rdv_id, applicant2.id, "sms", "rdv_created")
      expect(NotifyRdvToApplicantJob).to receive(:perform_async)
        .with(rdv_id, applicant2.id, "email", "rdv_created")
      subject
    end

    context "when phone number is not mobile" do
      before { applicant1.update!(phone_number: "0101010101") }

      it "does not enqueue a notification by sms job" do
        expect(NotifyRdvToApplicantJob).not_to receive(:perform_async)
          .with(rdv_id, applicant1.id, "sms", "rdv_created")
        subject
      end
    end

    context "when the phone number is blank" do
      before { applicant1.update!(phone_number: nil) }

      it "does not enqueue a notification by sms job" do
        expect(NotifyRdvToApplicantJob).not_to receive(:perform_async)
          .with(rdv_id, applicant1.id, "sms", "rdv_created")
        subject
      end
    end

    context "when there is no email" do
      before { applicant1.update!(email: nil) }

      it "does not enqueue a notification by email job" do
        expect(NotifyRdvToApplicantJob).not_to receive(:perform_async)
          .with(rdv_id, applicant1.id, "email", "rdv_created")
        subject
      end
    end
  end
end
