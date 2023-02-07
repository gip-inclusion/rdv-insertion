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
  let!(:configuration) { create(:configuration, motif_category: category_rsa_orientation) }
  let!(:organisation) { create(:organisation, configurations: [configuration], department: department) }

  let!(:invitation) do
    create(
      :invitation,
      applicant: applicant, department: department, rdv_solidarites_token: "123", help_phone_number: help_phone_number,
      number_of_days_to_accept_invitation: 9, organisations: [organisation],
      link: "https://www.rdv-solidarites.fr/lieux?invitation_token=123", format: "sms", rdv_context: rdv_context
    )
  end

  let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_orientation) }
  let!(:content) do
    "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous " \
      "d'orientation. " \
      "Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant " \
      "dans les 9 jours: http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
      "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le 0147200001."
  end

  describe "#call" do
    before do
      allow(Messengers::SendSms).to receive(:call).and_return(OpenStruct.new(success?: true))
      ENV["HOST"] = "www.rdv-insertion.fr"
    end

    it("is a success") { is_a_success }

    it "calls the messenger service service" do
      expect(Messengers::SendSms).to receive(:call)
        .with(sendable: invitation, content: content)
      subject
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
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: invitation, content: content)
        subject
      end
    end

    context "for rsa accompagnement" do
      let!(:rdv_context) { build(:rdv_context) }
      let!(:configuration) { create(:configuration) }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous " \
          "d'accompagnement." \
          " Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant " \
          "dans les 9 jours: http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
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
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: invitation, content: content)
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
            expect(Messengers::SendSms).to receive(:call)
              .with(sendable: invitation, content: content)
            subject
          end
        end
      end
    end

    context "for rsa orientation on phone platform" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_orientation_on_phone_platform) }
      let!(:configuration) { create(:configuration, motif_category: category_rsa_orientation_on_phone_platform) }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez contacter la plateforme départementale " \
          "afin de démarrer un parcours d'accompagnement. Pour cela, merci d'appeler le " \
          "0147200001 dans un délai de 9 jours. " \
          "Cet appel est nécessaire pour le traitement de votre dossier."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: invitation, content: content)
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
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: invitation, content: content)
          subject
        end
      end
    end

    context "for rsa cer signature" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_cer_signature) }
      let!(:configuration) { create(:configuration, motif_category: category_rsa_cer_signature) }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez vous présenter à " \
          "un rendez-vous de signature de CER." \
          " Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant dans les " \
          "9 jours: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "Ce rendez-vous est obligatoire. " \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: invitation, content: content)
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
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: invitation, content: content)
          subject
        end
      end
    end

    context "for rsa_main_tendue" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_main_tendue) }
      let!(:configuration) { create(:configuration, motif_category: category_rsa_main_tendue) }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez vous présenter à " \
          "un entretien de main tendue." \
          " Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant dans les " \
          "9 jours: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "Ce rendez-vous est obligatoire. " \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: invitation, content: content)
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
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: invitation, content: content)
          subject
        end
      end
    end

    context "for rsa_atelier_collectif_mandatory" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_atelier_collectif_mandatory) }
      let!(:configuration) { create(:configuration, motif_category: category_rsa_atelier_collectif_mandatory) }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un atelier collectif." \
          " Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant dans les " \
          "9 jours: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "Ce rendez-vous est obligatoire. " \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: invitation, content: content)
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
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: invitation, content: content)
          subject
        end
      end
    end

    context "for rsa_spie" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_spie) }
      let!(:configuration) { create(:configuration, motif_category: category_rsa_spie) }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes demandeur d'emploi et vous devez vous présenter à un rendez-vous " \
          "d'accompagnement." \
          " Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant " \
          "dans les 9 jours: http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "Ce rendez-vous est obligatoire. En l'absence d'action de votre part, " \
          "le versement de votre RSA pourra être suspendu ou réduit. " \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: invitation, content: content)
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
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: invitation, content: content)
          subject
        end
      end
    end

    context "for rsa_integration_information" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_integration_information) }
      let!(:configuration) { create(:configuration, motif_category: category_rsa_integration_information) }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous " \
          "d'information." \
          " Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant " \
          "dans les 9 jours: http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "Ce rendez-vous est obligatoire. " \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: invitation, content: content)
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
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: invitation, content: content)
          subject
        end
      end
    end
    # ici

    context "for rsa insertion offer" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_insertion_offer) }
      let!(:configuration) { create(:configuration, motif_category: category_rsa_insertion_offer) }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et bénéficiez d'un accompagnement en parcours " \
          "professionnel ou socio-professionel. Pour profiter au mieux de cet accompagnement, nous vous invitons " \
          "à vous inscrire directement et librement aux ateliers et formations de votre choix en cliquant sur le " \
          "lien suivant: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: invitation, content: content)
        subject
      end
    end

    context "for rsa_atelier_competences" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_atelier_competences) }
      let!(:configuration) { create(:configuration, motif_category: category_rsa_atelier_competences) }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et bénéficiez d'un accompagnement en parcours " \
          "professionnel ou socio-professionel. Pour profiter au mieux de cet accompagnement, nous vous invitons " \
          "à vous inscrire directement et librement aux ateliers et formations de votre choix en cliquant sur le " \
          "lien suivant: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: invitation, content: content)
        subject
      end
    end

    context "for rsa_atelier_rencontres_pro" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_atelier_rencontres_pro) }
      let!(:configuration) { create(:configuration, motif_category: category_rsa_atelier_rencontres_pro) }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et bénéficiez d'un accompagnement en parcours " \
          "professionnel ou socio-professionel. Pour profiter au mieux de cet accompagnement, nous vous invitons " \
          "à vous inscrire directement et librement aux ateliers et formations de votre choix en cliquant sur le " \
          "lien suivant: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: invitation, content: content)
        subject
      end
    end

    context "for rsa follow up" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_follow_up) }
      let!(:configuration) { create(:configuration, motif_category: category_rsa_follow_up) }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez vous présenter à " \
          "un rendez-vous de suivi. " \
          "Pour choisir la date et l'horaire du RDV, cliquez sur le lien suivant dans les " \
          "9 jours: " \
          "http://www.rdv-insertion.fr/invitations/redirect?uuid=#{invitation.uuid}\n" \
          "En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(Messengers::SendSms).to receive(:call)
          .with(sendable: invitation, content: content)
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
          expect(Messengers::SendSms).to receive(:call)
            .with(sendable: invitation, content: content)
          subject
        end
      end
    end
  end
end
