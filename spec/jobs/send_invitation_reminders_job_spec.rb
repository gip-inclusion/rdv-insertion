describe SendInvitationRemindersJob, type: :job do
  subject do
    described_class.new.perform
  end

  describe "#perform" do
    let!(:applicant1) { create(:applicant, email: "camille1@gouv.fr", phone_number: "0649031931") }
    let!(:applicant2) { create(:applicant, email: "camille2@gouv.fr", phone_number: "0649031932") }
    let!(:applicant3) { create(:applicant, email: "camille3@gouv.fr", phone_number: "0649031933") }
    let!(:applicant4) { create(:applicant, email: "camille4@gouv.fr", phone_number: "0649031934") }
    let!(:applicant5) { create(:applicant, email: "camille5@gouv.fr", phone_number: "0649031935", is_archived: true) }

    let!(:rdv_context1) { create(:rdv_context, status: "invitation_pending") }
    let!(:rdv_context2) { create(:rdv_context, status: "invitation_pending") }
    let!(:rdv_context3) { create(:rdv_context, status: "invitation_pending") }
    let!(:rdv_context4) { create(:rdv_context, status: "rdv_pending") }
    let!(:rdv_context5) { create(:rdv_context, status: "invitation_pending") }

    let!(:invitation1) do
      create(
        :invitation,
        applicant: applicant1, rdv_context: rdv_context1,
        sent_at: 3.days.ago, valid_until: 4.days.from_now
      )
    end

    let!(:invitation2) do
      create(
        :invitation,
        applicant: applicant2, rdv_context: rdv_context2,
        sent_at: 4.days.ago, valid_until: 4.days.from_now
      )
    end

    let!(:invitation3) do
      create(
        :invitation,
        applicant: applicant3, rdv_context: rdv_context3,
        sent_at: 3.days.ago, valid_until: 4.hours.from_now
      )
    end

    let!(:invitation4) do
      create(
        :invitation,
        applicant: applicant4, rdv_context: rdv_context4,
        sent_at: 3.days.ago, valid_until: 4.days.from_now
      )
    end

    let!(:invitation5) do
      create(
        :invitation,
        applicant: applicant5, rdv_context: rdv_context5,
        sent_at: 3.days.ago, valid_until: 4.days.from_now
      )
    end

    before do
      allow(SendInvitationReminderJob).to receive(:perform_async)
      allow(MattermostClient).to receive(:send_to_notif_channel)
    end

    it "enqueues reminder jobs for the eligible applicants only" do
      expect(SendInvitationReminderJob).to receive(:perform_async)
        .with(applicant1.id, "sms")
      expect(SendInvitationReminderJob).to receive(:perform_async)
        .with(applicant1.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(applicant2.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(applicant2.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(applicant3.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(applicant3.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(applicant4.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(applicant4.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(applicant5.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(applicant5.id, "email")
      subject
    end

    it "sends a notification to mattermost" do
      expect(MattermostClient).to receive(:send_to_notif_channel)
        .with(
          "📬 1 relances en cours!\n" \
          "Les allocataires sont: [#{applicant1.id}]"
        )
      subject
    end

    context "when the eligible applicants do not have email or phone number" do
      let!(:applicant1) { create(:applicant, phone_number: nil, email: "") }

      it "does not enqueue reminder jobs" do
        expect(SendInvitationReminderJob).not_to receive(:perform_async)
          .with(applicant1.id, "sms")
        expect(SendInvitationReminderJob).not_to receive(:perform_async)
          .with(applicant1.id, "email")
        subject
      end
    end
  end
end
