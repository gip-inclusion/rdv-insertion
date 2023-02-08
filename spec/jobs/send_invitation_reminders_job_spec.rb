describe SendInvitationRemindersJob do
  subject do
    described_class.new.perform
  end

  describe "#perform" do
    let!(:applicant1) { create(:applicant, email: "camille1@gouv.fr", phone_number: "0649031931") }
    let!(:applicant2) { create(:applicant, email: "camille2@gouv.fr", phone_number: "0649031932") }
    let!(:applicant3) { create(:applicant, email: "camille3@gouv.fr", phone_number: "0649031933") }
    let!(:applicant4) { create(:applicant, email: "camille4@gouv.fr", phone_number: "0649031934") }
    let!(:applicant5) do
      create(:applicant, email: "camille5@gouv.fr", phone_number: "0649031935", archived_at: 2.days.ago)
    end
    let!(:applicant6) { create(:applicant, email: "camille6@gouv.fr", phone_number: "0649031935") }

    let!(:rdv_context1) { create(:rdv_context, status: "invitation_pending", applicant: applicant1) }
    let!(:rdv_context2) { create(:rdv_context, status: "invitation_pending", applicant: applicant2) }
    let!(:rdv_context3) { create(:rdv_context, status: "invitation_pending", applicant: applicant3) }
    let!(:rdv_context4) { create(:rdv_context, status: "rdv_pending", applicant: applicant4) }
    let!(:rdv_context5) { create(:rdv_context, status: "invitation_pending", applicant: applicant5) }
    let!(:rdv_context6) do
      create(
        :rdv_context,
        status: "invitation_pending",
        motif_category: create(:motif_category, participation_optional: true),
        applicant: applicant6
      )
    end
    let!(:rdv_context7) { create(:rdv_context, status: "invitation_pending", applicant: applicant1) }

    # OK
    let!(:invitation1) do
      create(
        :invitation,
        applicant: applicant1, rdv_context: rdv_context1,
        sent_at: 3.days.ago, valid_until: 4.days.from_now
      )
    end

    # Not sent 3 days ago
    let!(:invitation2) do
      create(
        :invitation,
        applicant: applicant2, rdv_context: rdv_context2,
        sent_at: 4.days.ago, valid_until: 4.days.from_now
      )
    end

    # Not valid long enough
    let!(:invitation3) do
      create(
        :invitation,
        applicant: applicant3, rdv_context: rdv_context3,
        sent_at: 3.days.ago, valid_until: 4.hours.from_now
      )
    end

    # Status is not invitation_pending
    let!(:invitation4) do
      create(
        :invitation,
        applicant: applicant4, rdv_context: rdv_context4,
        sent_at: 3.days.ago, valid_until: 4.days.from_now
      )
    end

    # applicant is archived
    let!(:invitation5) do
      create(
        :invitation,
        applicant: applicant5, rdv_context: rdv_context5,
        sent_at: 3.days.ago, valid_until: 4.days.from_now
      )
    end

    # Motif Category not eligible for reminder
    let!(:invitation6) do
      create(
        :invitation,
        applicant: applicant6, rdv_context: rdv_context6,
        sent_at: 3.days.ago, valid_until: 4.days.from_now
      )
    end

    # Invitation is a reminder
    let!(:invitation7) do
      create(
        :invitation,
        applicant: applicant1, rdv_context: rdv_context7,
        sent_at: 3.days.ago, valid_until: 4.days.from_now,
        reminder: true
      )
    end

    before do
      allow(SendInvitationReminderJob).to receive(:perform_async)
      allow(MattermostClient).to receive(:send_to_notif_channel)
    end

    it "enqueues reminder jobs for the eligible contexts only" do
      expect(SendInvitationReminderJob).to receive(:perform_async)
        .with(rdv_context1.id, "sms")
      expect(SendInvitationReminderJob).to receive(:perform_async)
        .with(rdv_context1.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(rdv_context2.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(rdv_context2.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(rdv_context3.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(rdv_context3.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(rdv_context4.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(rdv_context4.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(rdv_context5.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(rdv_context5.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(rdv_context6.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(rdv_context6.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(rdv_context7.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_async)
        .with(rdv_context7.id, "email")
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

    context "when the eligible applicants do not have email or mobile phone number" do
      let!(:applicant1) { create(:applicant, phone_number: nil, email: "") }
      let!(:applicant2) { create(:applicant, phone_number: "0123456789", email: "") }

      it "does not enqueue reminder jobs" do
        expect(SendInvitationReminderJob).not_to receive(:perform_async)
          .with(rdv_context1.id, "sms")
        expect(SendInvitationReminderJob).not_to receive(:perform_async)
          .with(rdv_context2.id, "sms")
        expect(SendInvitationReminderJob).not_to receive(:perform_async)
          .with(rdv_context1.id, "email")
        expect(SendInvitationReminderJob).not_to receive(:perform_async)
          .with(rdv_context1.id, "email")
        subject
      end
    end
  end
end
