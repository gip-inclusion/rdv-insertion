describe Invitations::SendSms, type: :service do
  subject do
    described_class.call(
      invitation: invitation
    )
  end

  let!(:help_phone_number) { "0147200001" }
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
  let!(:configuration) { create(:configuration, motif_category: "rsa_orientation") }
  let!(:organisation) { create(:organisation, configurations: [configuration], department: department) }

  let!(:invitation) do
    create(
      :invitation,
      applicant: applicant, department: department, token: "123", help_phone_number: help_phone_number,
      number_of_days_to_accept_invitation: 9, organisations: [organisation],
      link: "https://www.rdv-solidarites.fr/lieux?invitation_token=123", format: "sms", rdv_context: rdv_context
    )
  end

  let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_orientation") }
  let!(:content) do
    "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous "\
      "d'orientation. Pour choisir la date et l'horaire de votre premier RDV, cliquez sur le lien suivant "\
      "dans les 9 jours: http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n"\
      "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le 0147200001."
  end

  describe "#call" do
    before do
      allow(SendTransactionalSms).to receive(:call)
      allow(Rails).to receive_message_chain(:env, :production?).and_return(true)
      ENV['HOST'] = "www.rdv-insertion.fr"
    end

    it("is a success") { is_a_success }

    it "calls the send transactional service" do
      expect(SendTransactionalSms).to receive(:call)
        .with(phone_number_formatted: phone_number_formatted,
              sender_name: "Dept#{department.number}",
              content: content)
      subject
    end

    context "when the phone number is blank" do
      let!(:phone_number) { '' }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Le téléphone doit être renseigné"])
      end
    end

    context "when the phone number is not a mobile" do
      let!(:phone_number) { '0123456789' }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Le numéro de téléphone doit être un mobile"])
      end
    end

    context "when the phone number is not a metropolitan mobile" do
      let!(:phone_number) { '0692926878' }

      it("is a success") { is_a_success }
    end

    context "when the invitation format is not sms" do
      let!(:invitation) do
        create(:invitation, applicant: applicant, format: "email")
      end

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Envoi de SMS alors que le format est email"])
      end
    end

    context "when it is a reminder" do
      let!(:content) do
        "Monsieur John DOE,\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours vous " \
          "invitant à prendre RDV au créneau de votre choix afin de démarrer un parcours d’accompagnement. " \
          "Le lien de prise de RDV suivant expire dans 5 jours: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le 0147200001."
      end

      before do
        invitation.update!(reminder: true, valid_until: 5.days.from_now)
      end

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number_formatted: phone_number_formatted,
                sender_name: "Dept#{department.number}",
                content: content)
        subject
      end
    end

    context "for rsa accompagnement" do
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_accompagnement") }
      let!(:configuration) { create(:configuration, motif_category: "rsa_accompagnement") }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous "\
          "d'accompagnement. Pour choisir la date et l'horaire de votre premier RDV, cliquez sur le lien suivant "\
          "dans les 9 jours: http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n"\
          "Ce rendez-vous est obligatoire. En l’absence d'action de votre part, " \
          "le versement de votre RSA pourra être suspendu ou réduit. " \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number_formatted: phone_number_formatted,
                sender_name: "Dept#{department.number}",
                content: content)
        subject
      end

      context "when it is a reminder" do
        let!(:content) do
          "Monsieur John DOE,\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours vous " \
            "invitant à prendre RDV au créneau de votre choix afin de démarrer un parcours d’accompagnement. " \
            "Le lien de prise de RDV suivant expire dans 5 jours: " \
            "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
            "Ce rendez-vous est obligatoire. En l’absence d'action de votre part, " \
            "le versement de votre RSA pourra être suspendu ou réduit. En cas de problème technique, contactez le "\
            "0147200001."
        end

        before do
          invitation.update!(reminder: true, valid_until: 5.days.from_now)
        end

        it "calls the send transactional service with the right content" do
          expect(SendTransactionalSms).to receive(:call)
            .with(phone_number_formatted: phone_number_formatted,
                  sender_name: "Dept#{department.number}",
                  content: content)
          subject
        end
      end
    end

    context "for rsa orientation on phone platform" do
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_orientation_on_phone_platform") }
      let!(:configuration) { create(:configuration, motif_category: "rsa_orientation_on_phone_platform") }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez contacter la plateforme départementale " \
          "afin de démarrer votre parcours d’accompagnement. Pour cela, merci d’appeler le " \
          "0147200001 dans un délai de 9 jours. "\
          "Cet appel est nécessaire pour le traitement de votre dossier."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number_formatted: phone_number_formatted,
                sender_name: "Dept#{department.number}",
                content: content)
        subject
      end

      context "when it is a reminder" do
        let!(:content) do
          "Monsieur John DOE,\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours vous " \
            "invitant à contacter la plateforme départementale afin de démarrer un parcours d’accompagnement. " \
            "Vous n'avez plus que 5 jours pour appeler le " \
            "0147200001. Cet appel est obligatoire pour le traitement de votre dossier."
        end

        before do
          invitation.update!(reminder: true, valid_until: 5.days.from_now)
        end

        it "calls the send transactional service with the right content" do
          expect(SendTransactionalSms).to receive(:call)
            .with(phone_number_formatted: phone_number_formatted,
                  sender_name: "Dept#{department.number}",
                  content: content)
          subject
        end
      end
    end

    context "for rsa cer signature" do
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_cer_signature") }
      let!(:configuration) { create(:configuration, motif_category: "rsa_cer_signature") }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et à ce titre vous allez construire et signer "\
          "votre Contrat d'Engagement Réciproque. Pour cela, nous vous invitons à prendre RDV avec votre référent de " \
          "parcours. Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant dans un délai de " \
          "9 jours: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n"\
          "En l'absence d'action de votre part, le versement de votre RSA pourra être suspendu ou réduit. "\
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number_formatted: phone_number_formatted,
                sender_name: "Dept#{department.number}",
                content: content)
        subject
      end

      context "when it is a reminder" do
        let!(:content) do
          "Monsieur John DOE,\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
            "vous invitant à prendre RDV au créneau de votre choix afin de signer votre Contrat d'Engagement " \
            "Réciproque. Le lien de prise de RDV suivant expire dans 5 jours: " \
            "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
            "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le "\
            "0147200001."
        end

        before do
          invitation.update!(reminder: true, valid_until: 5.days.from_now)
        end

        it "calls the send transactional service with the right content" do
          expect(SendTransactionalSms).to receive(:call)
            .with(phone_number_formatted: phone_number_formatted,
                  sender_name: "Dept#{department.number}",
                  content: content)
          subject
        end
      end
    end

    context "for rsa insertion offer" do
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_insertion_offer") }
      let!(:configuration) { create(:configuration, motif_category: "rsa_insertion_offer") }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et bénéficiez d'un accompagnement en parcours "\
          "professionnel ou socio-professionel. Pour profiter au mieux de cet accompagnement, nous vous invitons "\
          "à vous inscrire directement et librement aux ateliers et formations de votre choix en cliquant sur le " \
          "lien suivant: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n"\
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number_formatted: phone_number_formatted,
                sender_name: "Dept#{department.number}",
                content: content)
        subject
      end

      context "when it is a reminder" do
        let!(:content) do
          "Monsieur John DOE,\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
            "vous invitant à vous inscrire directement à des ateliers adaptés à votre parcours d'accompagnement." \
            "Utilisez le lien suivant pour effectuer votre prise de RDV: " \
            "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
            "En cas de problème technique, contactez le "\
            "0147200001."
        end

        before do
          invitation.update!(reminder: true, valid_until: 5.days.from_now)
        end

        it "calls the send transactional service with the right content" do
          expect(SendTransactionalSms).to receive(:call)
            .with(phone_number_formatted: phone_number_formatted,
                  sender_name: "Dept#{department.number}",
                  content: content)
          subject
        end
      end
    end

    context "for rsa follow up" do
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_follow_up") }
      let!(:configuration) { create(:configuration, motif_category: "rsa_follow_up") }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et à ce titre vous êtes invité "\
          "par votre référent de parcours à un RDV de suivi. " \
          "Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant dans un délai de " \
          "9 jours: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n"\
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number_formatted: phone_number_formatted,
                sender_name: "Dept#{department.number}",
                content: content)
        subject
      end

      context "when it is a reminder" do
        let!(:content) do
          "Monsieur John DOE,\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
            "vous invitant à prendre un RDV de suivi au créneau de votre choix." \
            "Le lien de prise de RDV suivant expire dans 5 jours: " \
            "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
            "En cas de problème technique, contactez le "\
            "0147200001."
        end

        before do
          invitation.update!(reminder: true, valid_until: 5.days.from_now)
        end

        it "calls the send transactional service with the right content" do
          expect(SendTransactionalSms).to receive(:call)
            .with(phone_number_formatted: phone_number_formatted,
                  sender_name: "Dept#{department.number}",
                  content: content)
          subject
        end
      end
    end

    context "when the sms sender name is defined in organisation configuration" do
      let!(:configuration) { create(:configuration, motif_category: "rsa_orientation") }
      let!(:invitation_parameters) { create(:invitation_parameters, sms_sender_name: "PoleRSA") }
      let!(:organisation) do
        create(:organisation, configurations: [configuration],
                              department: department,
                              invitation_parameters: invitation_parameters)
      end

      let!(:invitation) do
        create(
          :invitation,
          applicant: applicant, department: department, token: "123", help_phone_number: help_phone_number,
          number_of_days_to_accept_invitation: 9, organisations: [organisation],
          link: "https://www.rdv-solidarites.fr/lieux?invitation_token=123", format: "sms", rdv_context: rdv_context
        )
      end

      it("is a success") { is_a_success }

      it "sends the SMS with the right sender name" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number_formatted: phone_number_formatted,
                sender_name: "PoleRSA",
                content: content)
        subject
      end
    end
  end
end
