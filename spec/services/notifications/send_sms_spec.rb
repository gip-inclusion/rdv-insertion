describe Notifications::SendSms, type: :service do
  subject do
    described_class.call(
      notification: notification
    )
  end

  let!(:phone_number) { "0782605941" }
  let!(:phone_number_formatted) { "+33782605941" }
  let!(:applicant) do
    create(
      :applicant,
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
  let!(:rdv_context) { create(:rdv_context, motif_category: "rsa_orientation") }
  let!(:motif) { create(:motif, location_type: "public_office") }
  let!(:lieu) do
    create(:lieu, name: "DINUM", address: "20 avenue de Ségur 75007 Paris", phone_number: "0101010101")
  end
  let!(:rdv) do
    create(
      :rdv,
      motif: motif, lieu: lieu,
      starts_at: Time.zone.parse("20/12/2021 10:00")
    )
  end
  let!(:participation) do
    create(:participation, applicant: applicant, rdv: rdv, rdv_context: rdv_context)
  end
  let!(:notification) do
    create(:notification, participation: participation, format: "sms", event: "participation_created")
  end

  describe "#call" do
    before do
      allow(Messengers::SendSms).to receive(:call).and_return(OpenStruct.new(success?: true))
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

    describe "RSA orientation" do
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un " \
          "rendez-vous d'orientation. Vous êtes attendu(e) le 20/12/2021" \
          " à 10:00 ici: DINUM - 20 avenue de Ségur 75007 Paris. " \
          "Ce RDV est obligatoire. " \
          "En cas d’empêchement, appelez rapidement le 0101010101."
      end

      it "calls the messenger service with the right content" do
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: notification, content: content)
        subject
      end

      context "when is an update notification" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_updated")
        end

        let!(:content) do
          "Monsieur John DOE,\nVotre rendez-vous d'orientation dans le cadre de votre RSA a été modifié. " \
            "Vous êtes attendu(e) le 20/12/2021 à " \
            "10:00 ici: DINUM - 20 avenue de Ségur 75007 Paris. " \
            "Ce RDV est obligatoire. " \
            "En cas d’empêchement, appelez rapidement le 0101010101."
        end

        it "calls the messenger service with the right content" do
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: notification, content: content)
          subject
        end
      end

      context "when it is a cancelled notification" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_cancelled")
        end

        let!(:content) do
          "Monsieur John DOE,\nVotre rendez-vous d'orientation dans le cadre de votre RSA a été annulé. " \
            "Pour plus d'informations, contactez le 0101010101."
        end

        it "calls the messenger service with the right content" do
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: notification, content: content)
          subject
        end
      end

      context "when it is a phone rdv" do
        let!(:motif) { create(:motif, location_type: "phone") }

        let!(:content) do
          "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un " \
            "rendez-vous d'orientation." \
            " Un travailleur social vous appellera le 20/12/2021 à " \
            "partir de 10:00 sur ce numéro. " \
            "Ce RDV est obligatoire. " \
            "En cas d’empêchement, appelez rapidement le 0101010101."
        end

        it "calls the send transactional service with the right content" do
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: notification, content: content)
          subject
        end

        context "when it is an update notification" do
          let!(:notification) do
            create(:notification, participation: participation, format: "sms", event: "participation_updated")
          end

          let!(:content) do
            "Monsieur John DOE,\nVotre rendez-vous d'orientation dans le cadre de votre RSA a été modifié. " \
              "Un travailleur social vous appellera le 20/12/2021 à " \
              "partir de 10:00 sur ce numéro. " \
              "Ce RDV est obligatoire. " \
              "En cas d’empêchement, appelez rapidement le 0101010101."
          end

          it "calls the send transactional service with the right content" do
            expect(Messengers::SendSms).to receive(:call)
              .with(sendable: notification, content: content)
            subject
          end
        end
      end
    end

    describe "RSA accompagnement" do
      %w[rsa_accompagnement rsa_accompagnement_social rsa_accompagnement_sociopro].each do |motif_category|
        let!(:rdv_context) { create(:rdv_context, motif_category: motif_category) }

        let!(:content) do
          "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un " \
            "rendez-vous d'accompagnement. Vous êtes attendu(e) " \
            "le 20/12/2021 à 10:00 ici: DINUM - 20 avenue de Ségur 75007 Paris. " \
            "Ce RDV est obligatoire. " \
            "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit. " \
            "En cas d’empêchement, appelez rapidement le 0101010101."
        end

        it "calls the messenger service with the right content" do
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: notification, content: content)
          subject
        end

        context "when is an update notification" do
          let!(:notification) do
            create(:notification, participation: participation, format: "sms", event: "participation_updated")
          end

          let!(:content) do
            "Monsieur John DOE,\nVotre rendez-vous d'accompagnement dans le cadre de votre RSA a été modifié. " \
              "Vous êtes attendu(e) le 20/12/2021 à " \
              "10:00 ici: DINUM - 20 avenue de Ségur 75007 Paris. " \
              "Ce RDV est obligatoire. " \
              "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit. " \
              "En cas d’empêchement, appelez rapidement le 0101010101."
          end

          it "calls the messenger service with the right content" do
            expect(Messengers::SendSms).to receive(:call)
              .with(sendable: notification, content: content)
            subject
          end
        end

        context "when it is a cancelled notification" do
          let!(:notification) do
            create(:notification, participation: participation, format: "sms", event: "participation_cancelled")
          end

          let!(:content) do
            "Monsieur John DOE,\nVotre rendez-vous d'accompagnement dans le cadre de votre RSA a été annulé. " \
              "Pour plus d'informations, contactez le 0101010101."
          end

          it "calls the messenger service with the right content" do
            expect(Messengers::SendSms).to receive(:call)
              .with(sendable: notification, content: content)
            subject
          end
        end

        context "when it is a phone rdv" do
          let!(:motif) { create(:motif, location_type: "phone") }

          let!(:content) do
            "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un " \
              "rendez-vous d'accompagnement. Un travailleur social " \
              "vous appellera le 20/12/2021 à partir de 10:00 sur ce numéro. " \
              "Ce RDV est obligatoire. " \
              "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit. " \
              "En cas d’empêchement, appelez rapidement le 0101010101."
          end

          it "calls the send transactional service with the right content" do
            expect(Messengers::SendSms).to receive(:call)
              .with(sendable: notification, content: content)
            subject
          end

          context "when it is an update notification" do
            let!(:notification) do
              create(:notification, participation: participation, format: "sms", event: "participation_updated")
            end

            let!(:content) do
              "Monsieur John DOE,\nVotre rendez-vous d'accompagnement dans le cadre de votre RSA a été modifié. " \
                "Un travailleur social vous appellera le 20/12/2021 à " \
                "partir de 10:00 sur ce numéro. " \
                "Ce RDV est obligatoire. " \
                "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit. " \
                "En cas d’empêchement, appelez rapidement le 0101010101."
            end

            it "calls the send transactional service with the right content" do
              expect(Messengers::SendSms).to receive(:call)
                .with(sendable: notification, content: content)
              subject
            end
          end
        end
      end
    end

    describe "RSA CER Signature" do
      let!(:rdv_context) { create(:rdv_context, motif_category: "rsa_cer_signature") }

      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un " \
          "rendez-vous de signature de CER. " \
          "Vous êtes attendu(e) le 20/12/2021 à " \
          "10:00 ici: DINUM - 20 avenue de Ségur 75007 Paris. " \
          "Ce RDV est obligatoire. " \
          "En cas d’empêchement, appelez rapidement le 0101010101."
      end

      it "calls the messenger service with the right content" do
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: notification, content: content)
        subject
      end

      context "when is an update notification" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_updated")
        end

        let!(:content) do
          "Monsieur John DOE,\nVotre rendez-vous de signature de CER" \
            " dans le cadre de votre RSA a été modifié. " \
            "Vous êtes attendu(e) le 20/12/2021 à " \
            "10:00 ici: DINUM - 20 avenue de Ségur 75007 Paris. " \
            "Ce RDV est obligatoire. " \
            "En cas d’empêchement, appelez rapidement le 0101010101."
        end

        it "calls the messenger service with the right content" do
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: notification, content: content)
          subject
        end
      end

      context "when it is a cancelled notification" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_cancelled")
        end

        let!(:content) do
          "Monsieur John DOE,\nVotre rendez-vous de signature de CER" \
            " dans le cadre de votre RSA a été annulé. " \
            "Pour plus d'informations, contactez le 0101010101."
        end

        it "calls the messenger service with the right content" do
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: notification, content: content)
          subject
        end
      end

      context "when it is a phone rdv" do
        let!(:motif) { create(:motif, location_type: "phone") }

        let!(:content) do
          "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un " \
            "rendez-vous de signature de CER. " \
            "Un travailleur social vous appellera le 20/12/2021 à " \
            "partir de 10:00 sur ce numéro. " \
            "Ce RDV est obligatoire. " \
            "En cas d’empêchement, appelez rapidement le 0101010101."
        end

        it "calls the send transactional service with the right content" do
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: notification, content: content)
          subject
        end

        context "when it is an update notification" do
          let!(:notification) do
            create(:notification, participation: participation, format: "sms", event: "participation_updated")
          end

          let!(:content) do
            "Monsieur John DOE,\nVotre rendez-vous de signature de CER" \
              " dans le cadre de votre RSA a été modifié. " \
              "Un travailleur social vous appellera le 20/12/2021 à " \
              "partir de 10:00 sur ce numéro. " \
              "Ce RDV est obligatoire. " \
              "En cas d’empêchement, appelez rapidement le 0101010101."
          end

          it "calls the send transactional service with the right content" do
            expect(Messengers::SendSms).to receive(:call)
              .with(sendable: notification, content: content)
            subject
          end
        end
      end
    end

    describe "RSA suivi" do
      let!(:rdv_context) { create(:rdv_context, motif_category: "rsa_follow_up") }

      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un " \
          "rendez-vous de suivi. " \
          "Vous êtes attendu(e) le 20/12/2021 à " \
          "10:00 ici: DINUM - 20 avenue de Ségur 75007 Paris. " \
          "En cas d’empêchement, appelez rapidement le 0101010101."
      end

      it "calls the messenger service with the right content" do
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: notification, content: content)
        subject
      end

      context "when is an update notification" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_updated")
        end

        let!(:content) do
          "Monsieur John DOE,\nVotre rendez-vous de suivi dans le cadre de votre RSA a été modifié. " \
            "Vous êtes attendu(e) le 20/12/2021 à " \
            "10:00 ici: DINUM - 20 avenue de Ségur 75007 Paris. " \
            "En cas d’empêchement, appelez rapidement le 0101010101."
        end

        it "calls the messenger service with the right content" do
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: notification, content: content)
          subject
        end
      end

      context "when it is a cancelled notification" do
        let!(:notification) do
          create(:notification, participation: participation, format: "sms", event: "participation_cancelled")
        end

        let!(:content) do
          "Monsieur John DOE,\nVotre rendez-vous de suivi" \
            " dans le cadre de votre RSA a été annulé. " \
            "Pour plus d'informations, contactez le 0101010101."
        end

        it "calls the messenger service with the right content" do
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: notification, content: content)
          subject
        end
      end

      context "when it is a phone rdv" do
        let!(:motif) { create(:motif, location_type: "phone") }

        let!(:content) do
          "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un " \
            "rendez-vous de suivi. " \
            "Un travailleur social vous appellera le 20/12/2021 à " \
            "partir de 10:00 sur ce numéro. " \
            "En cas d’empêchement, appelez rapidement le 0101010101."
        end

        it "calls the send transactional service with the right content" do
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: notification, content: content)
          subject
        end

        context "when it is an update notification" do
          let!(:notification) do
            create(:notification, participation: participation, format: "sms", event: "participation_updated")
          end

          let!(:content) do
            "Monsieur John DOE,\nVotre rendez-vous de suivi" \
              " dans le cadre de votre RSA a été modifié. " \
              "Un travailleur social vous appellera le 20/12/2021 à " \
              "partir de 10:00 sur ce numéro. " \
              "En cas d’empêchement, appelez rapidement le 0101010101."
          end

          it "calls the send transactional service with the right content" do
            expect(Messengers::SendSms).to receive(:call)
              .with(sendable: notification, content: content)
            subject
          end
        end
      end
    end

    describe "RSA SPIE" do
      let!(:rdv_context) { create(:rdv_context, motif_category: "rsa_spie") }

      let!(:content) do
        "Monsieur John DOE,\nVous êtes demandeur d'emploi et à ce titre vous avez été convoqué(e) à un " \
          "rendez-vous d'accompagnement. Vous êtes attendu(e) " \
          "le 20/12/2021 à 10:00 ici: DINUM - 20 avenue de Ségur 75007 Paris. " \
          "Ce RDV est obligatoire. " \
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit. " \
          "En cas d’empêchement, appelez rapidement le 0101010101."
      end

      it "calls the messenger service with the right content" do
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: notification, content: content)
        subject
      end

      context "when is an update notification" do
        let!(:notification) do
          create(:notification, applicant: applicant, rdv: rdv, format: "sms", event: "rdv_updated")
        end

        let!(:content) do
          "Monsieur John DOE,\nVotre rendez-vous d'accompagnement dans le cadre de votre " \
            "demande d'emploi a été modifié. " \
            "Vous êtes attendu(e) le 20/12/2021 à " \
            "10:00 ici: DINUM - 20 avenue de Ségur 75007 Paris. " \
            "Ce RDV est obligatoire. " \
            "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit. " \
            "En cas d’empêchement, appelez rapidement le 0101010101."
        end

        it "calls the messenger service with the right content" do
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: notification, content: content)
          subject
        end
      end

      context "when it is a cancelled notification" do
        let!(:notification) do
          create(:notification, applicant: applicant, rdv: rdv, format: "sms", event: "rdv_cancelled")
        end

        let!(:content) do
          "Monsieur John DOE,\nVotre rendez-vous d'accompagnement dans le cadre de votre " \
            "demande d'emploi a été annulé. " \
            "Pour plus d'informations, contactez le 0101010101."
        end

        it "calls the messenger service with the right content" do
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: notification, content: content)
          subject
        end
      end

      context "when it is a phone rdv" do
        let!(:motif) { create(:motif, location_type: "phone") }

        let!(:content) do
          "Monsieur John DOE,\nVous êtes demandeur d'emploi et à ce titre vous avez été convoqué(e) à un " \
            "rendez-vous d'accompagnement. Un travailleur social " \
            "vous appellera le 20/12/2021 à partir de 10:00 sur ce numéro. " \
            "Ce RDV est obligatoire. " \
            "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit. " \
            "En cas d’empêchement, appelez rapidement le 0101010101."
        end

        it "calls the send transactional service with the right content" do
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: notification, content: content)
          subject
        end

        context "when it is an update notification" do
          let!(:notification) do
            create(:notification, applicant: applicant, rdv: rdv, format: "sms", event: "rdv_updated")
          end

          let!(:content) do
            "Monsieur John DOE,\nVotre rendez-vous d'accompagnement dans le cadre de votre " \
              "demande d'emploi a été modifié. " \
              "Un travailleur social vous appellera le 20/12/2021 à " \
              "partir de 10:00 sur ce numéro. " \
              "Ce RDV est obligatoire. " \
              "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit. " \
              "En cas d’empêchement, appelez rapidement le 0101010101."
          end

          it "calls the send transactional service with the right content" do
            expect(Messengers::SendSms).to receive(:call)
              .with(sendable: notification, content: content)
            subject
          end
        end
      end
    end
  end
end
