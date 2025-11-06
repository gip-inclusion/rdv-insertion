describe SendInvitationRemindersJob do
  subject do
    described_class.new.perform
  end

  describe "#perform" do
    let!(:user1) { create(:user, email: "camille1@gouv.fr", phone_number: "0649031931") }
    let!(:user2) { create(:user, email: "camille2@gouv.fr", phone_number: "0649031932") }
    let!(:user3) { create(:user, email: "camille3@gouv.fr", phone_number: "0649031933") }
    let!(:user4) { create(:user, email: "camille4@gouv.fr", phone_number: "0649031934") }
    let!(:user5) do
      create(:user, email: "camille5@gouv.fr", phone_number: "0649031935")
    end
    let!(:user6) { create(:user, email: "camille6@gouv.fr", phone_number: "0649031935") }
    let!(:user7) { create(:user, email: "camille7@gouv.fr", phone_number: "0649031937") }

    let!(:follow_up1) do
      create(:follow_up, status: "invitation_pending", user: user1)
    end
    let!(:follow_up2) do
      create(:follow_up, status: "invitation_pending", user: user2)
    end
    let!(:follow_up3) do
      create(:follow_up, status: "invitation_pending", user: user3)
    end
    let!(:follow_up4) { create(:follow_up, status: "rdv_pending", user: user4) }
    let!(:follow_up5) do
      create(:follow_up, status: "invitation_pending", user: user5)
    end
    let!(:follow_up6) do
      create(
        :follow_up,
        status: "invitation_pending",
        user: user6
      )
    end
    let!(:follow_up7) do
      create(:follow_up, status: "invitation_pending", user: user1)
    end
    let!(:follow_up8) do
      create(:follow_up, status: "invitation_pending", user: user7)
    end

    # OK
    let!(:invitation1) do
      create(
        :invitation,
        user: user1, follow_up: follow_up1,
        created_at: 3.days.ago, expires_at: 4.days.from_now
      )
    end

    # Not sent 3 days ago
    let!(:invitation2) do
      create(
        :invitation,
        user: user2, follow_up: follow_up2,
        created_at: 4.days.ago, expires_at: 4.days.from_now
      )
    end

    # Not valid long enough
    let!(:invitation3) do
      create(
        :invitation,
        user: user3, follow_up: follow_up3,
        created_at: 3.days.ago, expires_at: 4.hours.from_now
      )
    end

    # Status is not invitation_pending
    let!(:invitation4) do
      create(
        :invitation,
        user: user4, follow_up: follow_up4,
        created_at: 3.days.ago, expires_at: 4.days.from_now
      )
    end

    # Motif Category not eligible for reminder
    let!(:invitation6) do
      create(
        :invitation,
        user: user6, follow_up: follow_up6,
        created_at: 3.days.ago, expires_at: nil
      )
    end

    # Invitation is a reminder
    let!(:invitation7) do
      create(
        :invitation,
        user: user1, follow_up: follow_up7,
        created_at: 3.days.ago, expires_at: 4.days.from_now,
        trigger: "reminder"
      )
    end

    let!(:invitation8_old) do
      create(
        :invitation,
        user: user7, follow_up: follow_up8,
        created_at: 60.days.ago, expires_at: 50.days.ago
      )
    end
    let!(:invitation8_new) do
      create(
        :invitation,
        user: user7, follow_up: follow_up8,
        created_at: 3.days.ago, expires_at: 4.days.from_now
      )
    end

    before do
      allow(SendInvitationReminderJob).to receive(:perform_later)
      allow(SlackClient).to receive(:send_to_notif_channel)
    end

    it "enqueues reminder jobs for the eligible contexts only" do # rubocop:disable RSpec/ExampleLength
      expect(SendInvitationReminderJob).to receive(:perform_later)
        .with(follow_up1.id, "sms")
      expect(SendInvitationReminderJob).to receive(:perform_later)
        .with(follow_up1.id, "email")
      expect(SendInvitationReminderJob).to receive(:perform_later)
        .with(follow_up8.id, "sms")
      expect(SendInvitationReminderJob).to receive(:perform_later)
        .with(follow_up8.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_later)
        .with(follow_up2.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_later)
        .with(follow_up2.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_later)
        .with(follow_up3.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_later)
        .with(follow_up3.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_later)
        .with(follow_up4.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_later)
        .with(follow_up4.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_later)
        .with(follow_up5.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_later)
        .with(follow_up5.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_later)
        .with(follow_up6.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_later)
        .with(follow_up6.id, "email")
      expect(SendInvitationReminderJob).not_to receive(:perform_later)
        .with(follow_up7.id, "sms")
      expect(SendInvitationReminderJob).not_to receive(:perform_later)
        .with(follow_up7.id, "email")
      subject
    end

    it "sends a notification to slack" do
      expect(SlackClient).to receive(:send_to_notif_channel)
        .with(
          "📬 2 relances en cours!\n" \
          "Les usagers sont: [#{user1.id}, #{user7.id}]"
        )
      subject
    end

    context "when the eligible users do not have email or mobile phone number" do
      let!(:user1) { create(:user, phone_number: nil, email: "") }
      let!(:user2) { create(:user, phone_number: "0123456789", email: "") }

      it "does not enqueue reminder jobs" do
        expect(SendInvitationReminderJob).not_to receive(:perform_later)
          .with(follow_up1.id, "sms")
        expect(SendInvitationReminderJob).not_to receive(:perform_later)
          .with(follow_up2.id, "sms")
        expect(SendInvitationReminderJob).not_to receive(:perform_later)
          .with(follow_up1.id, "email")
        expect(SendInvitationReminderJob).not_to receive(:perform_later)
          .with(follow_up1.id, "email")
        subject
      end
    end
  end
end
