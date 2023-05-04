describe Invitations::SendSms, type: :service do
  subject do
    described_class.call(
      invitation: invitation
    )
  end

  include_context "with all existing categories"

  let!(:help_phone_number) { "0147200001" }
  let!(:phone_number) { "0782605941" }
  let!(:phone_number_formatted) { "+33782605941" }
  let!(:applicant) do
    create(
      :applicant,
      phone_number: phone_number,
      first_name: "john", last_name: "doe", title: "monsieur"
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
  let!(:organisation) { create(:organisation, department: department) }
  let!(:configuration) { create(:configuration, organisation: organisation, motif_category: category_rsa_orientation) }
  let!(:sms_sender_name) { "provider" }

  let!(:invitation) do
    create(
      :invitation,
      applicant: applicant, department: department, rdv_solidarites_token: "123", help_phone_number: help_phone_number,
      organisations: [organisation],
      link: "https://www.rdv-solidarites.fr/lieux?invitation_token=123", format: "sms", rdv_context: rdv_context
    )
  end

  let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_orientation) }
  let!(:content) do
    "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous êtes #{applicant.conjugate('invité')} à participer" \
      " à un rendez-vous d'orientation. " \
      "Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant " \
      "dans les 3 jours: http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
      "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le 0147200001."
  end

  describe "#call" do
    before do
      allow(SendTransactionalSms).to receive(:call).and_return(OpenStruct.new(success?: true))
      allow(invitation).to receive(:sms_sender_name).and_return(sms_sender_name)
      ENV["HOST"] = "www.rdv-insertion.fr"
    end

    it("is a success") { is_a_success }

    it "calls the send sms service with the right content" do
      expect(SendTransactionalSms).to receive(:call)
        .with(
          phone_number_formatted: phone_number_formatted, content: content,
          sender_name: sms_sender_name
        )
      subject
    end

    context "when the phone number is nil" do
      let!(:phone_number) { nil }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Le téléphone doit être renseigné"])
      end
    end

    context "when the phone number is not a mobile" do
      let!(:phone_number) { "0142249062" }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Le numéro de téléphone doit être un mobile"])
      end
    end

    context "when the invitation format is not sms" do
      before { invitation.format = "email" }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Envoi de SMS alors que le format est email"])
      end
    end

    context "when it is a reminder" do
      let!(:content) do
        "Monsieur John DOE,\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours vous " \
          "invitant à prendre RDV au créneau de votre choix afin de démarrer un parcours d'accompagnement. " \
          "Le lien de prise de RDV suivant expire dans 5 jours: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le 0147200001."
      end

      before do
        invitation.update!(reminder: true, valid_until: 5.days.from_now)
      end

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end
    end

    context "for rsa accompagnement" do
      let!(:rdv_context) { build(:rdv_context) }
      let!(:configuration) { create(:configuration, organisation: organisation) }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous êtes #{applicant.conjugate('invité')} à " \
          "participer à un rendez-vous d'accompagnement." \
          " Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant " \
          "dans les 3 jours: http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "Ce rendez-vous est obligatoire. En l'absence d'action de votre part, " \
          "le versement de votre RSA pourra être suspendu ou réduit. " \
          "En cas de problème technique, contactez le 0147200001."
      end

      %w[category_rsa_accompagnement category_rsa_accompagnement_social category_rsa_accompagnement_sociopro]
        .each do |motif_category|
        before do
          rdv_context.motif_category = send(motif_category)
          configuration.motif_category = send(motif_category)
        end

        it("is a success") { is_a_success }

        it "calls the send transactional service with the right content" do
          expect(SendTransactionalSms).to receive(:call)
            .with(
              phone_number_formatted: phone_number_formatted, content: content,
              sender_name: sms_sender_name
            )
          subject
        end

        context "when it is a reminder" do
          let!(:content) do
            "Monsieur John DOE,\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours vous " \
              "invitant à prendre RDV au créneau de votre choix afin de démarrer un parcours d'accompagnement. " \
              "Le lien de prise de RDV suivant expire dans 5 jours: " \
              "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
              "Ce rendez-vous est obligatoire. En l'absence d'action de votre part, " \
              "le versement de votre RSA pourra être suspendu ou réduit. En cas de problème technique, contactez le " \
              "0147200001."
          end

          before do
            invitation.update!(reminder: true, valid_until: 5.days.from_now)
          end

          it "calls the send transactional service with the right content" do
            expect(SendTransactionalSms).to receive(:call)
              .with(
                phone_number_formatted: phone_number_formatted, content: content,
                sender_name: sms_sender_name
              )
            subject
          end
        end
      end
    end

    context "for rsa orientation on phone platform" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_orientation_on_phone_platform) }
      let!(:configuration) do
        create(:configuration, organisation: organisation, motif_category: category_rsa_orientation_on_phone_platform)
      end
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez contacter la plateforme départementale " \
          "afin de démarrer un parcours d'accompagnement. Pour cela, merci d'appeler le " \
          "0147200001 dans un délai de 3 jours. " \
          "Cet appel est nécessaire pour le traitement de votre dossier."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end

      context "when it is a reminder" do
        let!(:content) do
          "Monsieur John DOE,\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours vous " \
            "invitant à contacter la plateforme départementale afin de démarrer un parcours d'accompagnement. " \
            "Vous n'avez plus que 5 jours pour appeler le " \
            "0147200001. Cet appel est obligatoire pour le traitement de votre dossier."
        end

        before do
          invitation.update!(reminder: true, valid_until: 5.days.from_now)
        end

        it "calls the send transactional service with the right content" do
          expect(SendTransactionalSms).to receive(:call)
            .with(
              phone_number_formatted: phone_number_formatted, content: content,
              sender_name: sms_sender_name
            )
          subject
        end
      end
    end

    context "for rsa cer signature" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_cer_signature) }
      let!(:configuration) do
        create(:configuration, organisation: organisation, motif_category: category_rsa_cer_signature)
      end
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous êtes #{applicant.conjugate('invité')} à participer" \
          " à un rendez-vous de signature de CER." \
          " Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant dans les " \
          "3 jours: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "Ce rendez-vous est obligatoire. " \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end

      context "when it is a reminder" do
        let!(:content) do
          "Monsieur John DOE,\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
            "vous invitant à prendre RDV au créneau de votre choix afin de construire et signer " \
            "votre Contrat d'Engagement Réciproque. " \
            "Le lien de prise de RDV suivant expire dans 5 jours: " \
            "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
            "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le " \
            "0147200001."
        end

        before do
          invitation.update!(reminder: true, valid_until: 5.days.from_now)
        end

        it "calls the send transactional service with the right content" do
          expect(SendTransactionalSms).to receive(:call)
            .with(
              phone_number_formatted: phone_number_formatted, content: content,
              sender_name: sms_sender_name
            )
          subject
        end
      end
    end

    context "for rsa_main_tendue" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_main_tendue) }
      let!(:configuration) do
        create(:configuration, organisation: organisation, motif_category: category_rsa_main_tendue)
      end
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous êtes #{applicant.conjugate('invité')} à participer" \
          " à un entretien de main tendue." \
          " Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant dans les " \
          "3 jours: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "Ce rendez-vous est obligatoire. " \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end

      context "when it is a reminder" do
        let!(:content) do
          "Monsieur John DOE,\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
            "vous invitant à prendre RDV au créneau de votre choix afin de faire le point sur votre situation." \
            " Le lien de prise de RDV suivant expire dans 5 jours: " \
            "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
            "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le " \
            "0147200001."
        end

        before do
          invitation.update!(reminder: true, valid_until: 5.days.from_now)
        end

        it "calls the send transactional service with the right content" do
          expect(SendTransactionalSms).to receive(:call)
            .with(
              phone_number_formatted: phone_number_formatted, content: content,
              sender_name: sms_sender_name
            )
          subject
        end
      end
    end

    context "for rsa_atelier_collectif_mandatory" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_atelier_collectif_mandatory) }
      let!(:configuration) do
        create(:configuration, organisation: organisation, motif_category: category_rsa_atelier_collectif_mandatory)
      end
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous êtes #{applicant.conjugate('invité')} à participer" \
          " à un atelier collectif. Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant dans les " \
          "3 jours: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "Ce rendez-vous est obligatoire. " \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end

      context "when it is a reminder" do
        let!(:content) do
          "Monsieur John DOE,\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
            "vous invitant à prendre RDV au créneau de votre choix afin de vous aider dans votre parcours d'insertion" \
            ". Le lien de prise de RDV suivant expire dans 5 jours: " \
            "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
            "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le " \
            "0147200001."
        end

        before do
          invitation.update!(reminder: true, valid_until: 5.days.from_now)
        end

        it "calls the send transactional service with the right content" do
          expect(SendTransactionalSms).to receive(:call)
            .with(
              phone_number_formatted: phone_number_formatted, content: content,
              sender_name: sms_sender_name
            )
          subject
        end
      end
    end

    context "for rsa_spie" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_spie) }
      let!(:configuration) { create(:configuration, organisation: organisation, motif_category: category_rsa_spie) }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes demandeur d'emploi et vous êtes #{applicant.conjugate('invité')} à participer" \
          " à un rendez-vous d'accompagnement." \
          " Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant " \
          "dans les 3 jours: http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "Ce rendez-vous est obligatoire. En l'absence d'action de votre part, " \
          "le versement de votre RSA pourra être suspendu ou réduit. " \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end

      context "when it is a reminder" do
        let!(:content) do
          "Monsieur John DOE,\nEn tant que demandeur d'emploi, vous avez reçu un message il y a 3 jours vous " \
            "invitant à prendre RDV au créneau de votre choix afin de démarrer un parcours d'accompagnement. " \
            "Le lien de prise de RDV suivant expire dans 5 jours: " \
            "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
            "Ce rendez-vous est obligatoire. En l'absence d'action de votre part, " \
            "le versement de votre RSA pourra être suspendu ou réduit. En cas de problème technique, contactez le " \
            "0147200001."
        end

        before do
          invitation.update!(reminder: true, valid_until: 5.days.from_now)
        end

        it "calls the send transactional service with the right content" do
          expect(SendTransactionalSms).to receive(:call)
            .with(
              phone_number_formatted: phone_number_formatted, content: content,
              sender_name: sms_sender_name
            )
          subject
        end
      end
    end

    context "for siae_interview" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_siae_interview) }
      let!(:configuration) do
        create(:configuration, organisation: organisation, motif_category: category_siae_interview)
      end
      let!(:content) do
        "Monsieur John DOE,\nVous êtes candidat.e dans une Structure d’Insertion par l’Activité Economique (SIAE)" \
          " et vous êtes #{applicant.conjugate('invité')} à participer à un entretien d'embauche." \
          " Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant " \
          "dans les 3 jours: http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end

      context "when it is a reminder" do
        let!(:content) do
          "Monsieur John DOE,\nEn tant que candidat.e dans une Structure d’Insertion par l’Activité Economique " \
            "(SIAE), vous avez reçu un message il y a 3 jours vous " \
            "invitant à prendre RDV au créneau de votre choix afin de poursuivre le processus de recrutement. " \
            "Le lien de prise de RDV suivant expire dans 5 jours: " \
            "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
            "En cas de problème technique, contactez le " \
            "0147200001."
        end

        before do
          invitation.update!(reminder: true, valid_until: 5.days.from_now)
        end

        it "calls the send transactional service with the right content" do
          expect(SendTransactionalSms).to receive(:call)
            .with(
              phone_number_formatted: phone_number_formatted, content: content,
              sender_name: sms_sender_name
            )
          subject
        end
      end
    end

    context "for psychologue" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_psychologue) }
      let!(:configuration) { create(:configuration, organisation: organisation, motif_category: category_psychologue) }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes invité à prendre un rendez-vous de suivi psychologue." \
          " Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end
    end

    context "for rsa_orientation_france_travail" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_orientation_france_travail) }
      let!(:configuration) do
        create(:configuration, organisation: organisation, motif_category: category_rsa_orientation_france_travail)
      end
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous êtes invité à participer à " \
          "un rendez-vous d'orientation." \
          " Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant dans les " \
          "3 jours: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "Ce rendez-vous est obligatoire. " \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end
    end

    context "for atelier_enfants_ados" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_atelier_enfants_ados) }
      let!(:configuration) do
        create(:configuration, organisation: organisation, motif_category: category_atelier_enfants_ados)
      end
      let!(:content) do
        "John Doe,\nTu es invité à participer à un atelier organisé par le département. " \
          "Nous te proposons de cliquer ci-dessous pour découvrir le programme. " \
          "Si tu es intéressé pour participer, tu n’auras qu’à cliquer et t’inscrire en ligne avec le lien suivant: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "En cas de problème technique, tu peux contacter le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end
    end

    context "for rsa_integration_information" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_integration_information) }
      let!(:configuration) do
        create(:configuration, organisation: organisation, motif_category: category_rsa_integration_information)
      end
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous êtes #{applicant.conjugate('invité')} à participer" \
          " à un rendez-vous d'information." \
          " Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant " \
          "dans les 3 jours: http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "Ce rendez-vous est obligatoire. " \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end

      context "when it is a reminder" do
        let!(:content) do
          "Monsieur John DOE,\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours vous " \
            "invitant à prendre RDV au créneau de votre choix afin de vous renseigner sur vos droits et vos devoirs. " \
            "Le lien de prise de RDV suivant expire dans 5 jours: " \
            "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
            "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le " \
            "0147200001."
        end

        before do
          invitation.update!(reminder: true, valid_until: 5.days.from_now)
        end

        it "calls the send transactional service with the right content" do
          expect(SendTransactionalSms).to receive(:call)
            .with(
              phone_number_formatted: phone_number_formatted, content: content,
              sender_name: sms_sender_name
            )
          subject
        end
      end
    end

    context "for rsa insertion offer" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_insertion_offer) }
      let!(:configuration) do
        create(:configuration, organisation: organisation, motif_category: category_rsa_insertion_offer)
      end
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et bénéficiez d'un accompagnement. " \
          "Pour en profiter au mieux, nous vous invitons " \
          "à vous inscrire directement et librement aux ateliers et formations de votre choix en cliquant sur le " \
          "lien suivant: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end
    end

    context "for rsa_atelier_competences" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_atelier_competences) }
      let!(:configuration) do
        create(:configuration, organisation: organisation, motif_category: category_rsa_atelier_competences)
      end
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et bénéficiez d'un accompagnement. " \
          "Pour en profiter au mieux, nous vous invitons " \
          "à vous inscrire directement et librement aux ateliers et formations de votre choix en cliquant sur le " \
          "lien suivant: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end
    end

    context "for rsa_atelier_rencontres_pro" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_atelier_rencontres_pro) }
      let!(:configuration) do
        create(:configuration, organisation: organisation, motif_category: category_rsa_atelier_rencontres_pro)
      end
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et bénéficiez d'un accompagnement. " \
          "Pour en profiter au mieux, nous vous invitons " \
          "à vous inscrire directement et librement aux ateliers et formations de votre choix en cliquant sur le " \
          "lien suivant: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end
    end

    context "for rsa follow up" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_follow_up) }
      let!(:configuration) do
        create(:configuration, organisation: organisation, motif_category: category_rsa_follow_up)
      end
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous êtes #{applicant.conjugate('invité')} à participer" \
          " à un rendez-vous de suivi. " \
          "Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant dans les " \
          "3 jours: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            phone_number_formatted: phone_number_formatted, content: content,
            sender_name: sms_sender_name
          )
        subject
      end

      context "when it is a reminder" do
        let!(:content) do
          "Monsieur John DOE,\nEn tant que bénéficiaire du RSA, vous avez reçu un message il y a 3 jours " \
            "vous invitant à prendre RDV au créneau de votre choix afin de faire un point avec votre référent" \
            " de parcours. " \
            "Le lien de prise de RDV suivant expire dans 5 jours: " \
            "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
            "En cas de problème technique, contactez le " \
            "0147200001."
        end

        before do
          invitation.update!(reminder: true, valid_until: 5.days.from_now)
        end

        it "calls the send transactional service with the right content" do
          expect(SendTransactionalSms).to receive(:call)
            .with(
              phone_number_formatted: phone_number_formatted, content: content,
              sender_name: sms_sender_name
            )
          subject
        end
      end
    end
  end
end
