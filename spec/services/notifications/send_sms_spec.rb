describe Notifications::SendSms, type: :service do
  subject do
    described_class.call(
      notification: notification
    )
  end

  include_context "with all existing categories"

  let!(:phone_number) { "+33782605941" }
  let!(:sms_sender_name) { "provider" }
  let!(:user) do
    create(
      :user,
      phone_number: phone_number,
      first_name: "John", last_name: "Doe", title: "monsieur"
    )
  end
  let!(:department) do
    create(
      :department,
      number: "26",
      name: "Drôme",
      region: "Auvergne-Rhône-Alpes"
    )
  end
  let!(:follow_up) { create(:follow_up, motif_category: category_rsa_orientation) }
  let!(:motif) do
    create(
      :motif, location_type: "public_office",
              instruction_for_rdv: "Merci de venir au RDV avec un justificatif de domicile et une pièce d'identité."
    )
  end
  let!(:lieu) do
    create(:lieu, name: "DINUM", address: "20 avenue de Ségur 75007 Paris", phone_number: "0101010101")
  end
  let!(:organisation) { create(:organisation) }
  let!(:rdv) do
    create(
      :rdv,
      motif: motif, lieu: lieu,
      starts_at: Time.zone.parse("20/12/2021 10:00"),
      organisation:
    )
  end
  let!(:participation) do
    create(:participation, user: user, rdv: rdv, follow_up: follow_up)
  end
  let!(:notification) do
    create(
      :notification,
      participation: participation, format: "sms", sms_provider: "brevo", event: "participation_created"
    )
  end

  let!(:content) do
    "Bonjour John Doe,\nVous êtes bénéficiaire du RSA et êtes convoqué à un " \
      "rendez-vous d'orientation. Vous êtes attendu le 20/12/21" \
      " à 10h à : DINUM - 20 avenue de Ségur 75007 Paris. " \
      "Ce RDV est obligatoire. " \
      "En cas d’empêchement, contactez le 0101010101."
  end

  describe "#call" do
    before do
      allow(notification).to receive(:sms_sender_name).and_return(sms_sender_name)
      allow(Sms::SendWithBrevo).to receive(:call).and_return(OpenStruct.new(success?: true))
    end

    it("is a success") { is_a_success }

    context "when it is neither a phone or public office rdv" do
      let!(:motif) { create(:motif, location_type: "home") }

      it "raises an error" do
        expect { subject }.to raise_error(
          SmsNotificationError, "Message de convocation non géré pour le rdv #{rdv.id}"
        )
      end
    end

    context "when the phone number is nil" do
      let!(:phone_number) { nil }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Le téléphone doit être renseigné"])
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
    end

    context "when the phone number is not a mobile" do
      let!(:phone_number) { "0142249062" }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Le numéro de téléphone doit être un mobile"])
      end
    end

    context "when the notification format is not sms" do
      before { notification.format = "email" }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Envoi de SMS alors que le format est email"])
      end
    end

    context "when the sms provider is primotexto" do
      before do
        notification.update!(sms_provider: "primotexto")
        allow(Sms::SendWithPrimotexto).to receive(:call).and_return(OpenStruct.new(success?: true))
      end

      it "calls the send sms with primotexto service with the right content" do
        expect(Sms::SendWithPrimotexto).to receive(:call)
          .with(
            phone_number: phone_number, content: content, sender_name: sms_sender_name
          )
        subject
      end

      it "is a success" do
        is_a_success
      end

      context "when the sms provider returns a failure" do
        before do
          allow(Sms::SendWithPrimotexto).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["some error"]))
        end

        it "is a failure" do
          is_a_failure
        end

        it "returns the error" do
          expect(subject.errors).to eq(["some error"])
        end
      end
    end

    describe "RSA orientation" do
      it "sends the sms with the right content" do
        expect(Sms::SendWithBrevo).to receive(:call)
          .with(
            phone_number: phone_number, content: content,
            sender_name: sms_sender_name, record_identifier: notification.record_identifier
          )
        subject
      end

      context "when it is a feminine user" do
        before do
          user.title = "madame"
          user.first_name = "Jane"
        end

        let!(:content) do
          "Bonjour Jane Doe,\nVous êtes bénéficiaire du RSA et êtes convoquée à un " \
            "rendez-vous d'orientation. Vous êtes attendue le 20/12/21" \
            " à 10h à : DINUM - 20 avenue de Ségur 75007 Paris. " \
            "Ce RDV est obligatoire. " \
            "En cas d’empêchement, contactez le 0101010101."
        end

        it "calls the messenger service with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end
      end

      context "when the user has no title" do
        before do
          user.update!(title: nil)
        end

        let!(:content) do
          "Bonjour John Doe,\nVous êtes bénéficiaire du RSA et êtes convoqué(e) à un " \
            "rendez-vous d'orientation. Vous êtes attendu(e) le 20/12/21" \
            " à 10h à : DINUM - 20 avenue de Ségur 75007 Paris. " \
            "Ce RDV est obligatoire. " \
            "En cas d’empêchement, contactez le 0101010101."
        end

        it "calls the messenger service with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end
      end

      context "when the template attributes are overriden by the category_configuration attributes" do
        let!(:category_configuration) do
          create(
            :category_configuration,
            organisation:,
            motif_category: category_rsa_orientation,
            template_user_designation_override: "joueur d'échec"
          )
        end

        let!(:content) do
          "Bonjour John Doe,\nVous êtes joueur d'échec et êtes convoqué à un " \
            "rendez-vous d'orientation. Vous êtes attendu le 20/12/21" \
            " à 10h à : DINUM - 20 avenue de Ségur 75007 Paris. " \
            "Ce RDV est obligatoire. " \
            "En cas d’empêchement, contactez le 0101010101."
        end

        it "calls the messenger service with the overriden content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end
      end

      context "when is an update notification" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_updated")
        end

        let!(:content) do
          "Bonjour John Doe,\nVotre rendez-vous d'orientation dans le cadre de votre RSA a été modifié. " \
            "Vous êtes attendu le 20/12/21 à " \
            "10h à : DINUM - 20 avenue de Ségur 75007 Paris. " \
            "Ce RDV est obligatoire. " \
            "En cas d’empêchement, contactez le 0101010101."
        end

        it "sends the sms with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end
      end

      context "when it's a reminder" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_reminder")
        end

        let!(:content) do
          "Rappel: Bonjour John Doe,\nVous êtes bénéficiaire du RSA et avez été convoqué à un " \
            "rendez-vous d'orientation. Vous êtes attendu le 20/12/21" \
            " à 10h à : DINUM - 20 avenue de Ségur 75007 Paris. " \
            "Ce RDV est obligatoire. " \
            "En cas d’empêchement, contactez le 0101010101."
        end

        it "sends the sms with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end
      end

      context "when it is a cancelled notification" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_cancelled")
        end

        let!(:content) do
          "Bonjour John Doe,\nVotre rendez-vous d'orientation du 20/12/21 à 10h " \
            "dans le cadre de votre RSA a été annulé. " \
            "Pour plus d'informations, contactez le 0101010101."
        end

        it "sends the sms with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end
      end

      context "when it is a phone rdv" do
        let!(:motif) { create(:motif, location_type: "phone") }

        let!(:content) do
          "Bonjour John Doe,\nVous êtes bénéficiaire du RSA et êtes convoqué à un " \
            "rendez-vous d'orientation téléphonique." \
            " Un conseiller d'insertion vous appellera le 20/12/21 à " \
            "partir de 10h sur ce numéro. " \
            "Ce RDV est obligatoire. " \
            "En cas d’empêchement, contactez le 0101010101."
        end

        it "calls the send transactional service with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end

        context "when it is an update notification" do
          let!(:notification) do
            create(:notification, participation: participation, format: "sms", event: "participation_updated")
          end

          let!(:content) do
            "Bonjour John Doe,\nVotre rendez-vous d'orientation téléphonique " \
              "dans le cadre de votre RSA a été modifié. " \
              "Un conseiller d'insertion vous appellera le 20/12/21 à " \
              "partir de 10h sur ce numéro. " \
              "Ce RDV est obligatoire. " \
              "En cas d’empêchement, contactez le 0101010101."
          end

          it "calls the send transactional service with the right content" do
            expect(Sms::SendWithBrevo).to receive(:call)
              .with(
                phone_number: phone_number, content: content,
                sender_name: sms_sender_name, record_identifier: notification.record_identifier
              )
            subject
          end
        end

        context "when it's a reminder" do
          let!(:notification) do
            create(:notification, participation: participation, format: "sms", event: "participation_reminder")
          end

          let!(:content) do
            "Rappel: Bonjour John Doe,\nVous êtes bénéficiaire du RSA et avez été convoqué à un " \
              "rendez-vous d'orientation téléphonique." \
              " Un conseiller d'insertion vous appellera le 20/12/21 à " \
              "partir de 10h sur ce numéro. " \
              "Ce RDV est obligatoire. " \
              "En cas d’empêchement, contactez le 0101010101."
          end

          it "sends the sms with the right content" do
            expect(Sms::SendWithBrevo).to receive(:call)
              .with(
                phone_number: phone_number, content: content,
                sender_name: sms_sender_name, record_identifier: notification.record_identifier
              )
            subject
          end
        end
      end
    end

    describe "RSA accompagnement" do
      %w[category_rsa_accompagnement category_rsa_accompagnement_social category_rsa_accompagnement_sociopro]
        .each do |motif_category|
          let!(:follow_up) { create(:follow_up, motif_category: send(motif_category)) }

          let!(:content) do
            "Bonjour John Doe,\nVous êtes bénéficiaire du RSA et êtes convoqué à un " \
              "rendez-vous d'accompagnement. Vous êtes attendu " \
              "le 20/12/21 à 10h à : DINUM - 20 avenue de Ségur 75007 Paris. " \
              "Ce RDV est obligatoire. " \
              "En cas d'absence, votre RSA pourra être suspendu ou réduit. " \
              "En cas d’empêchement, contactez le 0101010101."
          end

          it "sends the sms with the right content" do
            expect(Sms::SendWithBrevo).to receive(:call)
              .with(
                phone_number: phone_number, content: content,
                sender_name: sms_sender_name, record_identifier: notification.record_identifier
              )
            subject
          end

          context "when is an update notification" do
            let!(:notification) do
              create(:notification, participation: participation, format: "sms", event: "participation_updated")
            end

            let!(:content) do
              "Bonjour John Doe,\nVotre rendez-vous d'accompagnement dans le cadre de votre RSA a été modifié. " \
                "Vous êtes attendu le 20/12/21 à " \
                "10h à : DINUM - 20 avenue de Ségur 75007 Paris. " \
                "Ce RDV est obligatoire. " \
                "En cas d'absence, votre RSA pourra être suspendu ou réduit. " \
                "En cas d’empêchement, contactez le 0101010101."
            end

            it "sends the sms with the right content" do
              expect(Sms::SendWithBrevo).to receive(:call)
                .with(
                  phone_number: phone_number, content: content,
                  sender_name: sms_sender_name, record_identifier: notification.record_identifier
                )
              subject
            end
          end

          context "when it is a cancelled notification" do
            let!(:notification) do
              create(:notification, participation: participation, format: "sms", event: "participation_cancelled")
            end

            let!(:content) do
              "Bonjour John Doe,\nVotre rendez-vous d'accompagnement du 20/12/21 à 10h " \
                "dans le cadre de votre RSA a été annulé. " \
                "Pour plus d'informations, contactez le 0101010101."
            end

            it "sends the sms with the right content" do
              expect(Sms::SendWithBrevo).to receive(:call)
                .with(
                  phone_number: phone_number, content: content,
                  sender_name: sms_sender_name, record_identifier: notification.record_identifier
                )
              subject
            end
          end

          context "when it is a phone rdv" do
            let!(:motif) { create(:motif, location_type: "phone") }

            let!(:content) do
              "Bonjour John Doe,\nVous êtes bénéficiaire du RSA et êtes convoqué à un " \
                "rendez-vous d'accompagnement téléphonique. Un conseiller d'insertion " \
                "vous appellera le 20/12/21 à partir de 10h sur ce numéro. " \
                "Ce RDV est obligatoire. " \
                "En cas d'absence, votre RSA pourra être suspendu ou réduit. " \
                "En cas d’empêchement, contactez le 0101010101."
            end

            it "calls the send transactional service with the right content" do
              expect(Sms::SendWithBrevo).to receive(:call)
                .with(
                  phone_number: phone_number, content: content,
                  sender_name: sms_sender_name, record_identifier: notification.record_identifier
                )
              subject
            end

            context "when it is an update notification" do
              let!(:notification) do
                create(:notification, participation: participation, format: "sms", event: "participation_updated")
              end

              let!(:content) do
                "Bonjour John Doe,\nVotre rendez-vous d'accompagnement téléphonique " \
                  "dans le cadre de votre RSA a été modifié. " \
                  "Un conseiller d'insertion vous appellera le 20/12/21 à " \
                  "partir de 10h sur ce numéro. " \
                  "Ce RDV est obligatoire. " \
                  "En cas d'absence, votre RSA pourra être suspendu ou réduit. " \
                  "En cas d’empêchement, contactez le 0101010101."
              end

              it "calls the send transactional service with the right content" do
                expect(Sms::SendWithBrevo).to receive(:call)
                  .with(
                    phone_number: phone_number, content: content,
                    sender_name: sms_sender_name, record_identifier: notification.record_identifier
                  )
                subject
              end
            end
          end
      end
    end

    describe "RSA CER Signature" do
      let!(:motif) { create(:motif, location_type: "public_office") }
      let!(:follow_up) { create(:follow_up, motif_category: category_rsa_cer_signature) }

      let!(:content) do
        "Bonjour John Doe,\nVous êtes bénéficiaire du RSA et êtes convoqué à un " \
          "rendez-vous de signature de CER. " \
          "Vous êtes attendu le 20/12/21 à " \
          "10h à : DINUM - 20 avenue de Ségur 75007 Paris. " \
          "Ce RDV est obligatoire. " \
          "En cas d’empêchement, contactez le 0101010101."
      end

      it "sends the sms with the right content" do
        expect(Sms::SendWithBrevo).to receive(:call)
          .with(
            phone_number: phone_number, content: content,
            sender_name: sms_sender_name, record_identifier: notification.record_identifier
          )
        subject
      end

      context "when is an update notification" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_updated")
        end

        let!(:content) do
          "Bonjour John Doe,\nVotre rendez-vous de signature de CER" \
            " dans le cadre de votre RSA a été modifié. " \
            "Vous êtes attendu le 20/12/21 à " \
            "10h à : DINUM - 20 avenue de Ségur 75007 Paris. " \
            "Ce RDV est obligatoire. " \
            "En cas d’empêchement, contactez le 0101010101."
        end

        it "sends the sms with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end
      end

      context "when it is a cancelled notification" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_cancelled")
        end

        let!(:content) do
          "Bonjour John Doe,\nVotre rendez-vous de signature de CER " \
            "du 20/12/21 à 10h " \
            "dans le cadre de votre RSA a été annulé. " \
            "Pour plus d'informations, contactez le 0101010101."
        end

        it "sends the sms with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end
      end

      context "when it is a phone rdv" do
        let!(:motif) { create(:motif, location_type: "phone") }

        let!(:content) do
          "Bonjour John Doe,\nVous êtes bénéficiaire du RSA et êtes convoqué à un " \
            "rendez-vous téléphonique de signature de CER. " \
            "Un conseiller d'insertion vous appellera le 20/12/21 à " \
            "partir de 10h sur ce numéro. " \
            "Ce RDV est obligatoire. " \
            "En cas d’empêchement, contactez le 0101010101."
        end

        it "calls the send transactional service with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end

        context "when it is an update notification" do
          let!(:notification) do
            create(:notification, participation: participation, format: "sms", event: "participation_updated")
          end

          let!(:content) do
            "Bonjour John Doe,\nVotre rendez-vous téléphonique de signature de CER" \
              " dans le cadre de votre RSA a été modifié. " \
              "Un conseiller d'insertion vous appellera le 20/12/21 à " \
              "partir de 10h sur ce numéro. " \
              "Ce RDV est obligatoire. " \
              "En cas d’empêchement, contactez le 0101010101."
          end

          it "calls the send transactional service with the right content" do
            expect(Sms::SendWithBrevo).to receive(:call)
              .with(
                phone_number: phone_number, content: content,
                sender_name: sms_sender_name, record_identifier: notification.record_identifier
              )
            subject
          end
        end
      end
    end

    describe "RSA suivi" do
      let!(:motif) { create(:motif, location_type: "public_office") }
      let!(:follow_up) { create(:follow_up, motif_category: category_rsa_follow_up) }

      let!(:content) do
        "Bonjour John Doe,\nVous êtes bénéficiaire du RSA et êtes convoqué à un " \
          "rendez-vous de suivi. " \
          "Vous êtes attendu le 20/12/21 à " \
          "10h à : DINUM - 20 avenue de Ségur 75007 Paris. " \
          "En cas d’empêchement, contactez le 0101010101."
      end

      it "sends the sms with the right content" do
        expect(Sms::SendWithBrevo).to receive(:call)
          .with(
            phone_number: phone_number, content: content,
            sender_name: sms_sender_name, record_identifier: notification.record_identifier
          )
        subject
      end

      context "when is an update notification" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_updated")
        end

        let!(:content) do
          "Bonjour John Doe,\nVotre rendez-vous de suivi dans le cadre de votre RSA a été modifié. " \
            "Vous êtes attendu le 20/12/21 à " \
            "10h à : DINUM - 20 avenue de Ségur 75007 Paris. " \
            "En cas d’empêchement, contactez le 0101010101."
        end

        it "sends the sms with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end
      end

      context "when it is a cancelled notification" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_cancelled")
        end

        let!(:content) do
          "Bonjour John Doe,\nVotre rendez-vous de suivi du 20/12/21 à 10h " \
            "dans le cadre de votre RSA a été annulé. " \
            "Pour plus d'informations, contactez le 0101010101."
        end

        it "sends the sms with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end
      end

      context "when it is a phone rdv" do
        let!(:motif) { create(:motif, location_type: "phone") }

        let!(:content) do
          "Bonjour John Doe,\nVous êtes bénéficiaire du RSA et êtes convoqué à un " \
            "rendez-vous de suivi téléphonique. " \
            "Un conseiller d'insertion vous appellera le 20/12/21 à " \
            "partir de 10h sur ce numéro. " \
            "En cas d’empêchement, contactez le 0101010101."
        end

        it "calls the send transactional service with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end

        context "when it is an update notification" do
          let!(:notification) do
            create(:notification, participation: participation, format: "sms", event: "participation_updated")
          end

          let!(:content) do
            "Bonjour John Doe,\nVotre rendez-vous de suivi téléphonique" \
              " dans le cadre de votre RSA a été modifié. " \
              "Un conseiller d'insertion vous appellera le 20/12/21 à " \
              "partir de 10h sur ce numéro. " \
              "En cas d’empêchement, contactez le 0101010101."
          end

          it "calls the send transactional service with the right content" do
            expect(Sms::SendWithBrevo).to receive(:call)
              .with(
                phone_number: phone_number, content: content,
                sender_name: sms_sender_name, record_identifier: notification.record_identifier
              )
            subject
          end
        end
      end
    end

    describe "RSA SPIE" do
      let!(:motif) { create(:motif, location_type: "public_office") }
      let!(:follow_up) { create(:follow_up, motif_category: category_rsa_spie) }

      let!(:content) do
        "Bonjour John Doe,\nVous êtes demandeur d'emploi et êtes convoqué à un " \
          "rendez-vous d'accompagnement. Vous êtes attendu " \
          "le 20/12/21 à 10h à : DINUM - 20 avenue de Ségur 75007 Paris. " \
          "Ce RDV est obligatoire. " \
          "En cas d'absence, votre RSA pourra être suspendu ou réduit. " \
          "En cas d’empêchement, contactez le 0101010101."
      end

      it "sends the sms with the right content" do
        expect(Sms::SendWithBrevo).to receive(:call)
          .with(
            phone_number: phone_number, content: content,
            sender_name: sms_sender_name, record_identifier: notification.record_identifier
          )
        subject
      end

      context "when is an update notification" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_updated")
        end

        let!(:content) do
          "Bonjour John Doe,\nVotre rendez-vous d'accompagnement dans le cadre de votre " \
            "demande d'emploi a été modifié. " \
            "Vous êtes attendu le 20/12/21 à " \
            "10h à : DINUM - 20 avenue de Ségur 75007 Paris. " \
            "Ce RDV est obligatoire. " \
            "En cas d'absence, votre RSA pourra être suspendu ou réduit. " \
            "En cas d’empêchement, contactez le 0101010101."
        end

        it "sends the sms with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end
      end

      context "when it is a cancelled notification" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_cancelled")
        end

        let!(:content) do
          "Bonjour John Doe,\nVotre rendez-vous d'accompagnement du 20/12/21 à 10h " \
            "dans le cadre de votre demande d'emploi a été annulé. " \
            "Pour plus d'informations, contactez le 0101010101."
        end

        it "sends the sms with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end
      end

      context "when it is a phone rdv" do
        let!(:motif) { create(:motif, location_type: "phone") }

        let!(:content) do
          "Bonjour John Doe,\nVous êtes demandeur d'emploi et êtes convoqué à un " \
            "rendez-vous d'accompagnement téléphonique. Un conseiller d'insertion " \
            "vous appellera le 20/12/21 à partir de 10h sur ce numéro. " \
            "Ce RDV est obligatoire. " \
            "En cas d'absence, votre RSA pourra être suspendu ou réduit. " \
            "En cas d’empêchement, contactez le 0101010101."
        end

        it "calls the send transactional service with the right content" do
          expect(Sms::SendWithBrevo).to receive(:call)
            .with(
              phone_number: phone_number, content: content,
              sender_name: sms_sender_name, record_identifier: notification.record_identifier
            )
          subject
        end

        context "when it is an update notification" do
          let!(:notification) do
            create(:notification, participation: participation, format: "sms", event: "participation_updated")
          end

          let!(:content) do
            "Bonjour John Doe,\nVotre rendez-vous d'accompagnement téléphonique dans le cadre de votre " \
              "demande d'emploi a été modifié. " \
              "Un conseiller d'insertion vous appellera le 20/12/21 à " \
              "partir de 10h sur ce numéro. " \
              "Ce RDV est obligatoire. " \
              "En cas d'absence, votre RSA pourra être suspendu ou réduit. " \
              "En cas d’empêchement, contactez le 0101010101."
          end

          it "calls the send transactional service with the right content" do
            expect(Sms::SendWithBrevo).to receive(:call)
              .with(
                phone_number: phone_number, content: content,
                sender_name: sms_sender_name, record_identifier: notification.record_identifier
              )
            subject
          end
        end
      end
    end
  end
end
