describe Notifications::SendEmail, type: :service do
  subject do
    described_class.call(
      notification: notification
    )
  end

  let!(:mailer) { instance_double("mailer") }

  describe "#call" do
    before do
      allow(NotificationMailer).to receive(:with)
        .with(notification: notification)
        .and_return(mailer)
      allow(mailer).to receive_message_chain(:presential_participation_created, :deliver_now)
      allow(mailer).to receive_message_chain(:presential_participation_updated, :deliver_now)
      allow(mailer).to receive_message_chain(:by_phone_participation_created, :deliver_now)
      allow(mailer).to receive_message_chain(:by_phone_participation_updated, :deliver_now)
      allow(mailer).to receive_message_chain(:participation_cancelled, :deliver_now)
    end

    let!(:user) { create(:user) }
    let!(:organisation) { create(:organisation) }
    let!(:rdv) do
      create(
        :rdv,
        motif:,
        lieu:,
        organisation:
      )
    end
    let!(:lieu) do
      create(:lieu, name: "DINUM", address: "20 avenue de Ségur 75007 Paris", phone_number: "0101010101")
    end
    let!(:motif) { create(:motif, location_type: "public_office") }
    let!(:participation) do
      create(
        :participation,
        user: user, rdv: rdv
      )
    end
    let!(:notification) do
      create(:notification, participation: participation, event: "participation_created", format: "email")
    end

    context "for a public_office rdv" do
      before { allow(mailer).to receive_message_chain(:presential_participation_created, :deliver_now) }

      let!(:motif) { create(:motif, location_type: "public_office") }

      it("is a success") { is_a_success }

      it "calls the emailer service" do
        expect(mailer).to receive_message_chain(:presential_participation_created, :deliver_now)
        subject
      end

      context "for a rdv updated event" do
        let!(:notification) do
          create(:notification, participation: participation, event: "participation_updated", format: "email")
        end

        it "calls the emailer service with the right mailer method" do
          expect(mailer).to receive_message_chain(:presential_participation_updated, :deliver_now)
          subject
        end
      end

      context "for a rdv cancelled event" do
        let!(:notification) do
          create(:notification, participation: participation, event: "participation_cancelled", format: "email")
        end

        it "calls the emailer service with the right mailer method" do
          expect(mailer).to receive_message_chain(:participation_cancelled, :deliver_now)
          subject
        end
      end

      context "for a reminder event" do
        let!(:notification) do
          create(:notification, participation: participation, event: "participation_reminder", format: "email")
        end

        it "calls the emailer service with the right mailer method" do
          expect(mailer).to receive_message_chain(:presential_participation_reminder, :deliver_now)
          subject
        end
      end
    end

    context "for a phone rdv" do
      let!(:motif) { create(:motif, location_type: "phone") }

      context "for a rdv created event" do
        let!(:notification) do
          create(:notification, participation: participation, event: "participation_created", format: "email")
        end

        it "calls the emailer service with the right mailer method" do
          expect(mailer).to receive_message_chain(:by_phone_participation_created, :deliver_now)
          subject
        end
      end

      context "for a rdv updated event" do
        let!(:notification) do
          create(:notification, participation: participation, event: "participation_updated", format: "email")
        end

        it "calls the emailer service with the right mailer method" do
          allow(mailer).to receive_message_chain(:by_phone_participation_updated, :deliver_now)
          subject
        end
      end

      context "for a reminder event" do
        let!(:notification) do
          create(:notification, participation: participation, event: "participation_reminder", format: "email")
        end

        it "calls the emailer service with the right mailer method" do
          expect(mailer).to receive_message_chain(:by_phone_participation_reminder, :deliver_now)
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

    context "when the notification format is not email" do
      before { notification.format = "sms" }

      it("is a failure") { is_a_failure }

      it "returns an error" do
        expect(subject.errors).to eq(["Envoi d'un email alors que le format est sms"])
      end
    end

    context "when the structure phone number is empty" do
      let!(:lieu) do
        create(:lieu, name: "DINUM", address: "20 avenue de Ségur 75007 Paris", phone_number: "")
      end

      let!(:organisation) { create(:organisation, phone_number: nil) }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(
          ["Le numéro de téléphone de l'organisation, du lieu ou de la catégorie doit être renseigné"]
        )
      end

      it "sends a message to mattermost" do
        expect(MattermostClient).to receive(:send_to_private_channel).with(
          "Une convocation a été envoyée par l'organisation #{organisation.name} sans numéro de téléphone de " \
          "l'organisation, du lieu ou de la catégorie pour le rendez-vous avec l'ID #{rdv.id} " \
          "et l'usager avec l'ID #{user.id}."
        )
        subject
      end
    end

    context "when the email is blank" do
      before { user.email = nil }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["L'email doit être renseigné"])
      end
    end

    context "when the email format is not valid" do
      before { user.email = "someinvalidmail" }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["L'email renseigné ne semble pas être une adresse valable"])
      end
    end
  end
end
