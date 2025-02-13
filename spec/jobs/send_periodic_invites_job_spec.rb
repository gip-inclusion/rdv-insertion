describe SendPeriodicInvitesJob do
  subject do
    described_class.new.perform
  end

  describe "#perform" do
    let!(:organisation) { create(:organisation) }
    let!(:agent) { create(:agent, organisations: [organisation]) }
    let!(:category_configuration) do
      create(:category_configuration,
             organisation: organisation,
             number_of_days_between_periodic_invites: 15,
             number_of_days_before_invitations_expire: nil,
             motif_category: motif_category)
    end

    let!(:motif_category) { create(:motif_category) }
    let!(:follow_up) { create(:follow_up, motif_category: motif_category) }
    let!(:invitation) do
      create(
        :invitation,
        follow_up: follow_up,
        created_at: 15.days.ago,
        expires_at: nil,
        organisations: [organisation]
      )
    end

    context "when periodic invites are enabled" do
      context "number_of_days_between_periodic_invites is set" do
        context "when renewing is due" do
          it "sends periodic invites" do
            expect(SendPeriodicInviteJob).to receive(:perform_later).with(invitation.id, category_configuration.id,
                                                                          "email")
            expect(SendPeriodicInviteJob).to receive(:perform_later).with(invitation.id, category_configuration.id,
                                                                          "sms")
            subject
          end
        end

        context "when renewing is not due" do
          let!(:invitation) do
            create(
              :invitation,
              follow_up: follow_up,
              created_at: 3.days.ago,
              expires_at: 1.day.from_now,
              organisations: [organisation]
            )
          end

          it "does not send periodic invites" do
            expect(SendPeriodicInviteJob).not_to receive(:perform_later).with(invitation.id, category_configuration.id,
                                                                              "email")
            expect(SendPeriodicInviteJob).not_to receive(:perform_later).with(invitation.id, category_configuration.id,
                                                                              "sms")
            subject
          end
        end
      end

      context "day_of_the_month_periodic_invites is set" do
        let!(:category_configuration) do
          create(:category_configuration,
                 organisation: organisation,
                 day_of_the_month_periodic_invites: Time.zone.today.day,
                 number_of_days_before_invitations_expire: nil,
                 motif_category: motif_category)
        end

        context "when renewing is due" do
          it "sends periodic invites" do
            expect(SendPeriodicInviteJob).to receive(:perform_later).with(invitation.id, category_configuration.id,
                                                                          "email")
            expect(SendPeriodicInviteJob).to receive(:perform_later).with(invitation.id, category_configuration.id,
                                                                          "sms")
            subject
          end
        end

        context "when renewing is not due" do
          let!(:category_configuration) do
            create(:category_configuration,
                   organisation: organisation,
                   day_of_the_month_periodic_invites: Time.zone.yesterday.day,
                   number_of_days_before_invitations_expire: nil,
                   motif_category: motif_category)
          end

          it "sends periodic invites" do
            expect(SendPeriodicInviteJob).not_to receive(:perform_later).with(invitation.id, category_configuration.id,
                                                                              "email")
            expect(SendPeriodicInviteJob).not_to receive(:perform_later).with(invitation.id, category_configuration.id,
                                                                              "sms")
            subject
          end
        end

        context "when the last invitation was sent less than 10 days ago" do
          let!(:invitation) do
            create(:invitation,
                   follow_up: follow_up,
                   created_at: 9.days.ago,
                   expires_at: nil,
                   organisations: [organisation])
          end

          it "does not send periodic invites" do
            expect(SendPeriodicInviteJob).not_to receive(:perform_later).with(invitation.id, category_configuration.id,
                                                                              "email")
            expect(SendPeriodicInviteJob).not_to receive(:perform_later).with(invitation.id, category_configuration.id,
                                                                              "sms")
            subject
          end
        end
      end

      context "when no invitations have been sent" do
        let!(:invitation) do
          create(
            :invitation,
            follow_up: follow_up,
            created_at: nil,
            expires_at: 1.day.from_now,
            organisations: [organisation]
          )
        end

        it "does not send periodic invites" do
          expect(SendPeriodicInviteJob).not_to receive(:perform_later).with(invitation.id, category_configuration.id,
                                                                            "email")
          expect(SendPeriodicInviteJob).not_to receive(:perform_later).with(invitation.id, category_configuration.id,
                                                                            "sms")
          subject
        end
      end
    end

    context "when category_configuration is not set" do
      let!(:category_configuration) do
        create(:category_configuration,
               organisation: organisation,
               number_of_days_between_periodic_invites: nil,
               day_of_the_month_periodic_invites: nil,
               motif_category: motif_category)
      end

      it "does not send periodic invites" do
        expect(SendPeriodicInviteJob).not_to receive(:perform_later).with(invitation.id, category_configuration.id,
                                                                          "email")
        expect(SendPeriodicInviteJob).not_to receive(:perform_later).with(invitation.id, category_configuration.id,
                                                                          "sms")
        subject
      end
    end
  end
end
