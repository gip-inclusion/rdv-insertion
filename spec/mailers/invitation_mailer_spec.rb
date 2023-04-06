RSpec.describe InvitationMailer do
  include_context "with all existing categories"

  let!(:department) { create(:department, name: "Drôme", pronoun: "la") }
  let!(:help_phone_number) { "0139393939" }
  let!(:messages_configuration) { create(:messages_configuration) }
  let!(:organisation) { create(:organisation, department: department, messages_configuration: messages_configuration) }
  let!(:applicant) do
    create(:applicant, first_name: "Jean", last_name: "Valjean")
  end
  let!(:invitation) do
    create(
      :invitation,
      rdv_context: rdv_context, applicant: applicant, department: department,
      format: "email", help_phone_number: help_phone_number,
      organisations: [organisation]
    )
  end
  let!(:rdv_context) { build(:rdv_context) }

  describe "#standard_invitation" do
    subject do
      described_class.with(invitation: invitation, applicant: applicant).standard_invitation
    end

    context "for rsa_orientation" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_orientation) }

      it "renders the headers" do
        expect(subject.to).to eq([applicant.email])
      end

      it "renders the subject" do
        email_subject = unescape_html(subject.subject)
        expect(email_subject).to eq("[RSA]: Votre rendez-vous d'orientation dans le cadre de votre RSA")
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Bonjour Jean VALJEAN")
        expect(body_string).to match("Le département de la Drôme.")
        expect(body_string).to match("01 39 39 39 39")
        expect(body_string).to match(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes #{applicant.conjugate('invité')} à participer " \
          "à un rendez-vous d'orientation afin de démarrer un parcours d'accompagnement"
        )
        expect(body_string).to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 3 jours")
      end

      context "when the signature is configured" do
        let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

        it "renders the mail with the right signature" do
          expect(subject.body.encoded).to match(/Fabienne Bouchet/)
        end
      end
    end

    context "for rsa_accompagnement" do
      let!(:rdv_context) { build(:rdv_context) }

      %w[category_rsa_accompagnement category_rsa_accompagnement_social category_rsa_accompagnement_sociopro]
        .each do |motif_category|
        before { rdv_context.motif_category = send(motif_category) }

        it "renders the headers" do
          expect(subject.to).to eq([applicant.email])
        end

        it "renders the subject" do
          email_subject = unescape_html(subject.subject)
          expect(email_subject).to eq("[RSA]: Votre rendez-vous d'accompagnement dans le cadre de votre RSA")
        end

        it "renders the body" do
          body_string = unescape_html(subject.body.encoded)
          expect(body_string).to match("Bonjour Jean VALJEAN")
          expect(body_string).to match("Le département de la Drôme.")
          expect(body_string).to match("01 39 39 39 39")
          expect(body_string).to match(
            "Vous êtes bénéficiaire du RSA et à ce titre vous êtes #{applicant.conjugate('invité')} à participer " \
            "à un rendez-vous d'accompagnement afin de démarrer un parcours d'accompagnement"
          )
          expect(body_string).to match("Ce rendez-vous est obligatoire.")
          expect(body_string).to match(
            "le versement de votre RSA pourra être suspendu ou son montant réduit."
          )
          expect(body_string).to match("/invitations/redirect")
          expect(body_string).to match("uuid=#{invitation.uuid}")
          expect(body_string).to match("dans les 3 jours")
        end
      end
    end

    context "for rsa_cer_signature" do
      let!(:rdv_context) do
        build(:rdv_context, motif_category: category_rsa_cer_signature)
      end

      it "renders the headers" do
        expect(subject.to).to eq([applicant.email])
      end

      it "renders the subject" do
        email_subject = unescape_html(subject.subject)
        expect(email_subject).to eq(
          "[RSA]: Votre rendez-vous de signature de CER" \
          " dans le cadre de votre RSA"
        )
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Bonjour Jean VALJEAN")
        expect(body_string).to match("Le département de la Drôme.")
        expect(body_string).to match("01 39 39 39 39")
        expect(body_string).to match(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes #{applicant.conjugate('invité')} à participer à un " \
          "rendez-vous de signature de CER afin de construire et signer votre Contrat d'Engagement Réciproque"
        )
        expect(body_string).to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 3 jours")
      end
    end

    context "for rsa_follow_up" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_follow_up) }

      it "renders the headers" do
        expect(subject.to).to eq([applicant.email])
      end

      it "renders the subject" do
        email_subject = unescape_html(subject.subject)
        expect(email_subject).to eq(
          "[RSA]: Votre rendez-vous de suivi" \
          " dans le cadre de votre RSA"
        )
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Bonjour Jean VALJEAN")
        expect(body_string).to match("Le département de la Drôme.")
        expect(body_string).to match("01 39 39 39 39")
        expect(body_string).to match(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes #{applicant.conjugate('invité')} à participer " \
          "à un rendez-vous de suivi afin de faire un point avec votre référent de parcours"
        )
        expect(body_string).not_to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 3 jours")
      end
    end

    context "for rsa_main_tendue" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_main_tendue) }

      it "renders the headers" do
        expect(subject.to).to eq([applicant.email])
      end

      it "renders the subject" do
        email_subject = unescape_html(subject.subject)
        expect(email_subject).to eq(
          "[RSA]: Votre entretien de main tendue" \
          " dans le cadre de votre RSA"
        )
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Bonjour Jean VALJEAN")
        expect(body_string).to match("Le département de la Drôme.")
        expect(body_string).to match("01 39 39 39 39")
        expect(body_string).to match(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes #{applicant.conjugate('invité')} à participer " \
          "à un entretien de main tendue afin de faire le point sur votre situation"
        )
        expect(body_string).to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 3 jours")
      end
    end

    context "for rsa_atelier_collectif_mandatory" do
      let!(:rdv_context) do
        build(:rdv_context, motif_category: category_rsa_atelier_collectif_mandatory)
      end

      it "renders the headers" do
        expect(subject.to).to eq([applicant.email])
      end

      it "renders the subject" do
        email_subject = unescape_html(subject.subject)
        expect(email_subject).to eq(
          "[RSA]: Votre atelier collectif" \
          " dans le cadre de votre RSA"
        )
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Bonjour Jean VALJEAN")
        expect(body_string).to match("Le département de la Drôme.")
        expect(body_string).to match("01 39 39 39 39")
        expect(body_string).to match(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes #{applicant.conjugate('invité')} à participer " \
          "à un atelier collectif afin de vous aider dans votre parcours d'insertion"
        )
        expect(body_string).to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 3 jours")
      end
    end

    context "for rsa_spie" do
      let!(:rdv_context) do
        build(:rdv_context, motif_category: category_rsa_spie)
      end

      it "renders the headers" do
        expect(subject.to).to eq([applicant.email])
      end

      it "renders the subject" do
        email_subject = unescape_html(subject.subject)
        expect(email_subject).to(
          eq("[DEMANDE D'EMPLOI]: Votre rendez-vous d'accompagnement dans le cadre de votre demande d'emploi")
        )
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Bonjour Jean VALJEAN")
        expect(body_string).to match("Le département de la Drôme.")
        expect(body_string).to match("01 39 39 39 39")
        expect(body_string).to match(
          "Vous êtes demandeur d'emploi et à ce titre vous êtes #{applicant.conjugate('invité')} à participer à un " \
          "rendez-vous d'accompagnement afin de démarrer un parcours d'accompagnement"
        )
        expect(body_string).to match("Ce rendez-vous est obligatoire.")
        expect(body_string).to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 3 jours")
      end
    end

    context "for rsa integration information" do
      let!(:rdv_context) do
        build(:rdv_context, motif_category: category_rsa_integration_information)
      end

      it "renders the headers" do
        expect(subject.to).to eq([applicant.email])
      end

      it "renders the subject" do
        email_subject = unescape_html(subject.subject)
        expect(email_subject).to eq("[RSA]: Votre rendez-vous d'information dans le cadre de votre RSA")
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Bonjour Jean VALJEAN")
        expect(body_string).to match("Le département de la Drôme.")
        expect(body_string).to match("01 39 39 39 39")
        expect(body_string).to match(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes #{applicant.conjugate('invité')} à participer " \
          "à un rendez-vous d'information afin de vous renseigner sur vos droits et vos devoirs"
        )
        expect(body_string).to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 3 jours")
      end
    end

    context "for siae_interview" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_siae_interview) }

      it "renders the headers" do
        expect(subject.to).to eq([applicant.email])
      end

      it "renders the subject" do
        email_subject = unescape_html(subject.subject)
        expect(email_subject).to eq(
          "[CANDIDATURE SIAE]: Votre entretien d'embauche dans le cadre de votre candidature SIAE"
        )
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Bonjour Jean VALJEAN")
        expect(body_string).to match("Le département de la Drôme.")
        expect(body_string).to match("01 39 39 39 39")
        expect(body_string).to include(
          "Vous êtes candidat.e dans une Structure d’Insertion par l’Activité Economique (SIAE)" \
          " et à ce titre vous êtes #{applicant.conjugate('invité')} à participer à un entretien d'embauche " \
          "afin de poursuivre le processus de recrutement"
        )
        expect(body_string).not_to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 3 jours")
      end
    end

    context "for rsa_orientation_france_travail" do
      let!(:rdv_context) do
        build(:rdv_context, motif_category: category_rsa_orientation_france_travail)
      end

      it "renders the headers" do
        expect(subject.to).to eq([applicant.email])
      end

      it "renders the subject" do
        email_subject = unescape_html(subject.subject)
        expect(email_subject).to eq(
          "[RSA]: Votre rendez-vous d'orientation dans le cadre de votre RSA"
        )
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Bonjour Jean VALJEAN")
        expect(body_string).to match("Le département de la Drôme.")
        expect(body_string).to match("01 39 39 39 39")
        expect(body_string).to match("Dans le cadre du projet 'France Travail'")
        expect(body_string).to match("afin de démarrer un parcours d'accompagnement.")
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
      end
    end
  end

  describe "#invitation_for_rsa_orientation_on_phone_platform" do
    subject do
      described_class
        .with(invitation: invitation, applicant: applicant)
        .phone_platform_invitation
    end

    let!(:rdv_context) do
      build(:rdv_context, motif_category: category_rsa_orientation_on_phone_platform)
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("[RSA]: Votre rendez-vous d'orientation téléphonique dans le cadre de votre RSA")
    end

    it "renders the body" do
      body_string = unescape_html(subject.body.encoded)
      expect(body_string).to match("Bonjour Jean VALJEAN")
      expect(body_string).to match("Le département de la Drôme.")
      expect(body_string).to match("01 39 39 39 39")
      expect(body_string).to match(
        "En tant que bénéficiaire du RSA vous devez contacter la plateforme départementale" \
        " afin de démarrer un parcours d'accompagnement"
      )
      expect(body_string).not_to match("/invitations/redirect")
      expect(body_string).to match("dans un délai de 3 jours")
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end
  end

  describe "#atelier_invitation" do
    subject do
      described_class
        .with(invitation: invitation, applicant: applicant)
        .atelier_invitation
    end

    let!(:rdv_context) do
      build(:rdv_context, motif_category: category_rsa_atelier_rencontres_pro)
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      email_subject = unescape_html(subject.subject)
      expect(email_subject).to eq(
        "[RSA]: Participer à un atelier dans le cadre de votre parcours"
      )
    end

    it "renders the body" do
      body_string = unescape_html(subject.body.encoded)
      expect(body_string).to match("Bonjour Jean VALJEAN")
      expect(body_string).to match("Le département de la Drôme.")
      expect(body_string).to match("01 39 39 39 39")
      expect(body_string).to match(
        "Vous êtes bénéficiaire du RSA et bénéficiez d'un accompagnement. " \
        "Pour en profiter au mieux," \
        " nous vous invitons à vous inscrire directement et librement aux ateliers et formations de votre choix."
      )
      expect(body_string).to match("/invitations/redirect")
      expect(body_string).to match("uuid=#{invitation.uuid}")
      expect(body_string).not_to match("dans un délai de 3 jours")
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end
  end

  describe "#short_invitation" do
    subject do
      described_class
        .with(invitation: invitation, applicant: applicant)
        .short_invitation
    end

    context "for psychologue" do
      let!(:rdv_context) do
        build(:rdv_context, motif_category: category_psychologue)
      end

      it "renders the headers" do
        expect(subject.to).to eq([applicant.email])
      end

      it "renders the subject" do
        email_subject = unescape_html(subject.subject)
        expect(email_subject).to eq("Votre rendez-vous de suivi psychologue")
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Bonjour Jean VALJEAN")
        expect(body_string).to match("Le département de la Drôme.")
        expect(body_string).to match("01 39 39 39 39")
        expect(body_string).to match("Vous êtes invité pour un rendez-vous de suivi psychologue.")
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
      end
    end
  end

  describe "#standard_invitation_reminder" do
    subject do
      described_class.with(invitation: invitation, applicant: applicant).standard_invitation_reminder
    end

    context "for rsa_orientation" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_orientation) }

      it "renders the headers" do
        expect(subject.to).to eq([applicant.email])
      end

      it "renders the subject" do
        email_subject = unescape_html(subject.subject)
        expect(email_subject).to eq("[Rappel]: Votre rendez-vous d'orientation dans le cadre de votre RSA")
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Bonjour Jean VALJEAN")
        expect(body_string).to match("Le département de la Drôme.")
        expect(body_string).to match("01 39 39 39 39")
        expect(body_string).to match(
          "En tant que bénéficiaire du RSA, vous avez reçu un premier mail il y a 3 jours " \
          "vous invitant à prendre rendez-vous afin de démarrer un parcours d'accompagnement."
        )
        expect(body_string).to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match(
          "Il ne vous reste plus que <span class=\"font-weight-bold\">#{invitation.number_of_days_before_expiration}" \
          " jours</span> pour prendre rendez-vous"
        )
      end
    end

    context "when the signature is configured" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_orientation) }
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end

    context "for rsa_accompagnement" do
      %w[category_rsa_accompagnement category_rsa_accompagnement_social category_rsa_accompagnement_sociopro]
        .each do |motif_category|
        before { rdv_context.motif_category = send(motif_category) }

        it "renders the headers" do
          expect(subject.to).to eq([applicant.email])
        end

        it "renders the subject" do
          email_subject = unescape_html(subject.subject)
          expect(email_subject).to eq("[Rappel]: Votre rendez-vous d'accompagnement dans le cadre de votre RSA")
        end

        it "renders the body" do
          body_string = unescape_html(subject.body.encoded)
          expect(body_string).to match("Bonjour Jean VALJEAN")
          expect(body_string).to match("Le département de la Drôme.")
          expect(body_string).to match("01 39 39 39 39")
          expect(body_string).to match(
            "En tant que bénéficiaire du RSA, vous avez reçu un premier mail il y a 3 jours " \
            "vous invitant à prendre rendez-vous afin de démarrer un parcours d'accompagnement."
          )
          expect(body_string).to match("Ce rendez-vous est obligatoire.")
          expect(body_string).to match(
            "le versement de votre RSA pourra être suspendu ou son montant réduit."
          )
          expect(body_string).to match("/invitations/redirect")
          expect(body_string).to match("uuid=#{invitation.uuid}")
          expect(body_string).to match(
            "Il ne vous reste plus que <span class=\"font-weight-bold\">" \
            "#{invitation.number_of_days_before_expiration}" \
            " jours</span> pour prendre rendez-vous"
          )
        end
      end
    end

    context "for rsa_cer_signature" do
      let!(:rdv_context) do
        build(:rdv_context, motif_category: category_rsa_cer_signature)
      end

      it "renders the headers" do
        expect(subject.to).to eq([applicant.email])
      end

      it "renders the subject" do
        email_subject = unescape_html(subject.subject)
        expect(email_subject).to eq(
          "[Rappel]: Votre rendez-vous de signature de CER " \
          "dans le cadre de votre RSA"
        )
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Bonjour Jean VALJEAN")
        expect(body_string).to match("Le département de la Drôme.")
        expect(body_string).to match("01 39 39 39 39")
        expect(body_string).to match(
          "En tant que bénéficiaire du RSA, vous avez reçu un premier mail il y a 3 jours " \
          "vous invitant à prendre rendez-vous afin de construire et signer votre Contrat d'Engagement Réciproque."
        )
        expect(body_string).to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match(
          "Il ne vous reste plus que <span class=\"font-weight-bold\">#{invitation.number_of_days_before_expiration}" \
          " jours</span> pour prendre rendez-vous"
        )
      end
    end

    context "for rsa_follow_up" do
      let!(:rdv_context) { build(:rdv_context, motif_category: category_rsa_follow_up) }

      it "renders the headers" do
        expect(subject.to).to eq([applicant.email])
      end

      it "renders the subject" do
        email_subject = unescape_html(subject.subject)
        expect(email_subject).to eq(
          "[Rappel]: Votre rendez-vous de suivi " \
          "dans le cadre de votre RSA"
        )
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Bonjour Jean VALJEAN")
        expect(body_string).to match("Le département de la Drôme.")
        expect(body_string).to match("01 39 39 39 39")
        expect(body_string).to match(
          "En tant que bénéficiaire du RSA, vous avez reçu un premier mail il y a 3 jours " \
          "vous invitant à prendre rendez-vous afin de faire un point avec votre référent de parcours."
        )
        expect(body_string).not_to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match(
          "Il ne vous reste plus que <span class=\"font-weight-bold\">#{invitation.number_of_days_before_expiration}" \
          " jours</span> pour prendre rendez-vous"
        )
      end
    end
  end

  describe "#phone_platform_reminder" do
    subject do
      described_class
        .with(invitation: invitation, applicant: applicant)
        .phone_platform_invitation_reminder
    end

    let!(:rdv_context) do
      build(:rdv_context, motif_category: category_rsa_orientation_on_phone_platform)
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("[Rappel]: Votre rendez-vous d'orientation téléphonique dans le cadre de votre RSA")
    end

    it "renders the body" do
      body_string = unescape_html(subject.body.encoded)
      expect(body_string).to match("Bonjour Jean VALJEAN")
      expect(body_string).to match("Le département de la Drôme.")
      expect(body_string).to match(
        "En tant que bénéficiaire du RSA, vous avez reçu un premier mail il y a 3 jours vous invitant à contacter" \
        " la plateforme départementale afin de démarrer un parcours d'accompagnement."
      )
      expect(body_string).not_to match("/invitations/redirect")
      expect(body_string).not_to match("uuid=#{invitation.uuid}")
      expect(body_string).to match(
        "Il ne vous reste plus que <span class=\"font-weight-bold\">#{invitation.number_of_days_before_expiration}" \
        " jours</span> pour appeler le <span class=\"font-weight-bold\">01 39 39 39 39</span>."
      )
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end
  end
end
