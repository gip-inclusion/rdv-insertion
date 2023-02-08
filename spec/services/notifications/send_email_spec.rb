describe Notifications::SendEmail, type: :service do
  subject do
    described_class.call(
      notification: notification
    )
  end

  describe "#call" do
    before do
      allow(Messengers::SendEmail).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
    end

    let!(:applicant) { create(:applicant) }
    let!(:rdv) do
      create(
        :rdv,
        motif: motif
      )
    end
    let!(:participation) do
      create(
        :participation,
        applicant: applicant, rdv: rdv
      )
    end
    let!(:notification) do
      create(:notification, participation: participation, event: "participation_created")
    end

    context "for a public_office rdv" do
      let!(:motif) { create(:motif, location_type: "public_office") }

      it("is a success") { is_a_success }

      it "calls the emailer service" do
        expect(Messengers::SendEmail).to receive(:call)
          .with(
            sendable: notification,
            mailer_class: NotificationMailer,
            mailer_method: :presential_participation_created,
            notification: notification
          )
        subject
      end

      context "for a rdv updated event" do
        let!(:notification) do
          create(:notification, participation: participation, event: "participation_updated")
        end

        it "calls the emailer service with the right mailer method" do
          expect(Messengers::SendEmail).to receive(:call)
            .with(
              sendable: notification,
              mailer_class: NotificationMailer,
              mailer_method: :presential_participation_updated,
              notification: notification
            )
          subject
        end
      end

      context "for a rdv cancelled event" do
        let!(:notification) do
          create(:notification, participation: participation, event: "participation_cancelled")
        end

        it "calls the emailer service with the right mailer method" do
          expect(Messengers::SendEmail).to receive(:call)
            .with(
              sendable: notification,
              mailer_class: NotificationMailer,
              mailer_method: :participation_cancelled,
              notification: notification
            )
          subject
        end
      end
    end

    context "for a phone rdv" do
      let!(:motif) { create(:motif, location_type: "phone") }

      context "for a rdv created event" do
        let!(:notification) do
          create(:notification, participation: participation, event: "participation_created")
        end

        it "calls the emailer service with the right mailer method" do
          expect(Messengers::SendEmail).to receive(:call)
            .with(
              sendable: notification,
              mailer_class: NotificationMailer,
              mailer_method: :by_phone_participation_created,
              notification: notification
            )
          subject
        end
      end

      context "for a rdv updated event" do
        let!(:notification) do
          create(:notification, participation: participation, event: "participation_updated")
        end

        it "calls the emailer service with the right mailer method" do
          expect(Messengers::SendEmail).to receive(:call)
            .with(
              sendable: notification,
              mailer_class: NotificationMailer,
              mailer_method: :by_phone_participation_updated,
              notification: notification
            )
          subject
        end
      end
    end

    context "when the rdv is neither by phone nor in a public office" do
      let!(:motif) { create(:motif, location_type: "home") }

      it "raises an error" do
        expect { subject }.to raise_error(
          EmailNotificationError, "Message de convocation non géré pour le rdv #{rdv.id}"
        )
      end
    end
  end
end
