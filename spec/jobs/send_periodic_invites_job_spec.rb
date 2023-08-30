describe SendPeriodicInvitesJob do
  subject do
    described_class.new.perform
  end

  describe "#perform" do
    let!(:organisation) { create(:organisation) }
    let!(:configuration) do
      create(:configuration,
             organisation: organisation,
             number_of_days_before_next_invite: 5,
             motif_category: motif_category)
    end

    let!(:motif_category) { create(:motif_category, participation_optional: false) }
    let!(:rdv_context) { create(:rdv_context, motif_category: motif_category) }
    let!(:invitation) do
      create(
        :invitation,
        rdv_context: rdv_context,
        sent_at: 5.days.ago,
        valid_until: 1.day.from_now,
        organisations: [organisation]
      )
    end

    context "when renewing is due" do
      it "sends periodic invites" do
        expect(SendPeriodicInviteJob).to receive(:perform_async).with(invitation.id, configuration.id, "email")
        expect(SendPeriodicInviteJob).to receive(:perform_async).with(invitation.id, configuration.id, "sms")
        subject
      end
    end

    context "when renewing is not due" do
      let!(:invitation) do
        create(
          :invitation,
          rdv_context: rdv_context,
          sent_at: 3.days.ago,
          valid_until: 1.day.from_now,
          organisations: [organisation]
        )
      end

      it "does not send periodic invites" do
        expect(SendPeriodicInviteJob).not_to receive(:perform_async).with(invitation.id, configuration.id, "email")
        expect(SendPeriodicInviteJob).not_to receive(:perform_async).with(invitation.id, configuration.id, "sms")
        subject
      end
    end
  end
end
