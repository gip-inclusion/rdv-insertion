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
    let!(:organisation) do
      create(
        :organisation,
        messages_configuration: build(:messages_configuration, signature_lines: ["Signé par la DINUM"])
      )
    end
    let!(:rdv) do
      create(
        :rdv,
        organisation: organisation,
        motif: motif
      )
    end
    let!(:motif_category) { create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation") }
    let!(:participation) do
      create(
        :participation,
        applicant: applicant, rdv: rdv,
        rdv_context: build(:rdv_context, motif_category: motif_category)
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
            applicant: applicant,
            rdv: rdv,
            signature_lines: ["Signé par la DINUM"],
            motif_category: motif_category
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
              applicant: applicant,
              rdv: rdv,
              signature_lines: ["Signé par la DINUM"],
              motif_category: motif_category
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
              applicant: applicant,
              rdv: rdv,
              signature_lines: ["Signé par la DINUM"],
              motif_category: motif_category
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
              applicant: applicant,
              rdv: rdv,
              signature_lines: ["Signé par la DINUM"],
              motif_category: motif_category
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
              applicant: applicant,
              rdv: rdv,
              signature_lines: ["Signé par la DINUM"],
              motif_category: motif_category
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
