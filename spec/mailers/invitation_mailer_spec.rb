RSpec.describe InvitationMailer do
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
      number_of_days_to_accept_invitation: 5, organisations: [organisation]
    )
  end
  let!(:rdv_context) { build(:rdv_context) }

  describe "#regular_invitation" do
    subject do
      described_class.with(invitation: invitation, applicant: applicant).regular_invitation
    end

    context "for rsa_orientation" do
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_orientation") }

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
          "Vous êtes bénéficiaire du RSA et à ce titre vous devez vous présenter à un rendez-vous d'orientation" \
          " afin de démarrer un parcours d'accompagnement"
        )
        expect(body_string).to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 5 jours")
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

      %w[rsa_accompagnement rsa_accompagnement_social rsa_accompagnement_sociopro]
        .each do |motif_category|
        before { rdv_context.motif_category = motif_category }

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
            "Vous êtes bénéficiaire du RSA et à ce titre vous devez vous présenter à un rendez-vous d'accompagnement" \
            " afin de démarrer un parcours d'accompagnement"
          )
          expect(body_string).to match("Ce rendez-vous est obligatoire.")
          expect(body_string).to match(
            "le versement de votre RSA pourra être suspendu ou son montant réduit."
          )
          expect(body_string).to match("/invitations/redirect")
          expect(body_string).to match("uuid=#{invitation.uuid}")
          expect(body_string).to match("dans les 5 jours")
        end
      end
    end

    context "for rsa_cer_signature" do
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_cer_signature") }

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
          "Vous êtes bénéficiaire du RSA et à ce titre vous devez vous présenter à un rendez-vous de signature de " \
          "CER afin de construire et signer votre Contrat d'Engagement Réciproque"
        )
        expect(body_string).to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 5 jours")
      end
    end

    context "for rsa_follow_up" do
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_follow_up") }

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
          "Vous êtes bénéficiaire du RSA et à ce titre vous devez vous présenter à un rendez-vous " \
          "de suivi afin de faire un point avec votre référent de parcours"
        )
        expect(body_string).not_to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 5 jours")
      end
    end

    context "for rsa_main_tendue" do
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_main_tendue") }

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
          "Vous êtes bénéficiaire du RSA et à ce titre vous devez vous présenter à un entretien de main tendue " \
          "afin de faire le point sur votre situation"
        )
        expect(body_string).to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 5 jours")
      end
    end

    context "for rsa_atelier_collectif_mandatory" do
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_atelier_collectif_mandatory") }

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
          "Vous êtes bénéficiaire du RSA et à ce titre vous devez vous présenter à un atelier collectif " \
          "afin de vous aider dans votre parcours d'insertion"
        )
        expect(body_string).to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 5 jours")
      end
    end

    context "for rsa_spie" do
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_spie") }

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
          "Vous êtes demandeur d'emploi et à ce titre vous devez vous présenter à un rendez-vous d'accompagnement" \
          " afin de démarrer un parcours d'accompagnement"
        )
        expect(body_string).to match("Ce rendez-vous est obligatoire.")
        expect(body_string).to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 5 jours")
      end
    end

    context "for rsa integration information" do
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_integration_information") }

      it "renders the headers" do
        expect(subject.to).to eq([applicant.email])
      end

      it "renders the subject" do
        email_subject = unescape_html(subject.subject)
        expect(email_subject).to eq("[RSA]: Votre rendez-vous d'intégration dans le cadre de votre RSA")
      end

      it "renders the body" do
        body_string = unescape_html(subject.body.encoded)
        expect(body_string).to match("Bonjour Jean VALJEAN")
        expect(body_string).to match("Le département de la Drôme.")
        expect(body_string).to match("01 39 39 39 39")
        expect(body_string).to match(
          "Vous êtes bénéficiaire du RSA et à ce titre vous devez vous présenter à un rendez-vous d'intégration" \
          " afin de vous informer sur vos droits et vos devoirs"
        )
        expect(body_string).to match("Ce rendez-vous est obligatoire.")
        expect(body_string).not_to match(
          "le versement de votre RSA pourra être suspendu ou son montant réduit."
        )
        expect(body_string).to match("/invitations/redirect")
        expect(body_string).to match("uuid=#{invitation.uuid}")
        expect(body_string).to match("dans les 5 jours")
      end
    end
  end

  describe "#invitation_for_rsa_orientation_on_phone_platform" do
    subject do
      described_class
        .with(invitation: invitation, applicant: applicant)
        .invitation_for_rsa_orientation_on_phone_platform
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("[RSA]: Votre RDV d'orientation téléphonique dans le cadre de votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "En tant que bénéficiaire du RSA vous devez contacter la plateforme départementale" \
        " afin de démarrer votre parcours d’accompagnement"
      )
      expect(subject.body.encoded).not_to match("/invitations/redirect")
      expect(subject.body.encoded).to match("dans un délai de 5 jours")
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end
  end

  describe "#invitation_for_rsa_insertion_offer" do
    subject do
      described_class
        .with(invitation: invitation, applicant: applicant)
        .invitation_for_rsa_insertion_offer
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      email_subject = unescape_html(subject.subject)
      expect(email_subject).to eq(
        "[RSA]: Offre de formations et ateliers dans le cadre de votre parcours socio-professionel"
      )
    end

    it "renders the body" do
      body_string = unescape_html(subject.body.encoded)
      expect(body_string).to match("Bonjour Jean VALJEAN")
      expect(body_string).to match("Le département de la Drôme.")
      expect(body_string).to match("01 39 39 39 39")
      expect(body_string).to match(
        "Vous êtes bénéficiaire du RSA et bénéficiez d'un accompagnement " \
        "en parcours professionnel ou socio-professionel. Pour profiter au mieux de cet accompagnement," \
        " nous vous invitons à vous inscrire directement et librement aux ateliers et formations de votre choix."
      )
      expect(body_string).to match("/invitations/redirect")
      expect(body_string).to match("uuid=#{invitation.uuid}")
      expect(body_string).not_to match("dans un délai de 5 jours")
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end
  end

  describe "#regular_invitation_reminder" do
    subject do
      described_class.with(invitation: invitation, applicant: applicant).regular_invitation_reminder
    end

    context "for rsa_orientation" do
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_orientation") }

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
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end

    context "for rsa_accompagnement" do
      %w[rsa_accompagnement rsa_accompagnement_social rsa_accompagnement_sociopro]
        .each do |motif_category|
        before { rdv_context.motif_category = motif_category }

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
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_cer_signature") }

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
      let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_follow_up") }

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

  describe "#invitation_for_rsa_orientation_on_phone_platform_reminder" do
    subject do
      described_class
        .with(invitation: invitation, applicant: applicant)
        .invitation_for_rsa_orientation_on_phone_platform_reminder
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("[Rappel]: RDV d'orientation téléphonique dans le cadre de votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match(
        "En tant que bénéficiaire du RSA, vous avez reçu un premier mail il y a 3 jours vous invitant à contacter" \
        " la plateforme départementale afin de démarrer un parcours d’accompagnement."
      )
      expect(subject.body.encoded).not_to match("/invitations/redirect")
      expect(subject.body.encoded).not_to match("uuid=#{invitation.uuid}")
      expect(subject.body.encoded).to match(
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
