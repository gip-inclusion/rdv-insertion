RSpec.describe InvitationMailer, type: :mailer do
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
      applicant: applicant, department: department, format: "email", help_phone_number: help_phone_number,
      number_of_days_to_accept_invitation: 5, organisations: [organisation]
    )
  end

  describe "#invitation_for_rsa_orientation" do
    subject do
      described_class.with(invitation: invitation, applicant: applicant).invitation_for_rsa_orientation
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("Votre RDV d'orientation dans le cadre de votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "Vous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous d'orientation"
      )
      expect(subject.body.encoded).to match("/invitations/redirect")
      expect(subject.body.encoded).to match("uuid=#{invitation.uuid}")
      expect(subject.body.encoded).to match("dans les 5 jours")
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end
  end

  describe "#invitation_for_rsa_accompagnement" do
    subject do
      described_class.with(invitation: invitation, applicant: applicant)
                     .invitation_for_rsa_accompagnement
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("Votre RDV d'accompagnement dans le cadre de votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "Vous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous d'accompagnement."
      )
      expect(subject.body.encoded).to match("/invitations/redirect")
      expect(subject.body.encoded).to match("uuid=#{invitation.uuid}")
      expect(subject.body.encoded).to match("dans les 5 jours")
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end
  end

  describe "#invitation_for_rsa_accompagnement_social" do
    subject do
      described_class.with(invitation: invitation, applicant: applicant)
                     .invitation_for_rsa_accompagnement_social
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("Votre RDV d'accompagnement dans le cadre de votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "Vous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous d'accompagnement."
      )
      expect(subject.body.encoded).to match("/invitations/redirect")
      expect(subject.body.encoded).to match("uuid=#{invitation.uuid}")
      expect(subject.body.encoded).to match("dans les 5 jours")
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end
  end

  describe "#invitation_for_rsa_accompagnement_sociopro" do
    subject do
      described_class.with(invitation: invitation, applicant: applicant)
                     .invitation_for_rsa_accompagnement_sociopro
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("Votre RDV d'accompagnement dans le cadre de votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "Vous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous d'accompagnement."
      )
      expect(subject.body.encoded).to match("/invitations/redirect")
      expect(subject.body.encoded).to match("uuid=#{invitation.uuid}")
      expect(subject.body.encoded).to match("dans les 5 jours")
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
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
      expect(subject.subject).to eq("Votre RDV d'orientation téléphonique dans le cadre de votre RSA")
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

  describe "#invitation_for_rsa_cer_signature" do
    subject do
      described_class
        .with(invitation: invitation, applicant: applicant)
        .invitation_for_rsa_cer_signature
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("Votre RDV de signature de Contrat d'Engagement Réciproque" \
                                    " dans le cadre de votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "Vous êtes bénéficiaire du RSA et à ce titre vous allez construire et signer" \
        " votre Contrat d'Engagement Réciproque."
      )
      expect(subject.body.encoded).to match("/invitations/redirect")
      expect(subject.body.encoded).to match("uuid=#{invitation.uuid}")
      expect(subject.body.encoded).to match("dans les 5 jours")
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end
  end

  describe "#invitation_for_rsa_follow_up" do
    subject do
      described_class
        .with(invitation: invitation, applicant: applicant)
        .invitation_for_rsa_follow_up
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("Votre RDV de suivi avec votre référent de parcours")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "Vous êtes bénéficiaire du RSA et à ce titre vous êtes invité par votre référent de parcours" \
        " à un rendez-vous de suivi."
      )
      expect(subject.body.encoded).to match("/invitations/redirect")
      expect(subject.body.encoded).to match("uuid=#{invitation.uuid}")
      expect(subject.body.encoded).to match("dans les 5 jours")
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end
  end

  describe "#invitation_for_rsa_orientation_reminder" do
    subject do
      described_class.with(invitation: invitation, applicant: applicant).invitation_for_rsa_orientation_reminder
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("[Rappel]: RDV d'orientation dans le cadre de votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "En tant que bénéficiaire du RSA, vous avez reçu un premier mail il y a 3 jours vous invitant à prendre" \
        " rendez-vous afin de démarrer un parcours d’accompagnement."
      )
      expect(subject.body.encoded).to match("/invitations/redirect")
      expect(subject.body.encoded).to match("uuid=#{invitation.uuid}")
      expect(subject.body.encoded).to match(
        "Il ne vous reste plus que <span class=\"font-weight-bold\">#{invitation.number_of_days_before_expiration}" \
        " jours</span> pour prendre rendez-vous"
      )
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end
  end

  describe "#invitation_for_rsa_accompagnement_reminder" do
    subject do
      described_class.with(invitation: invitation, applicant: applicant)
                     .invitation_for_rsa_accompagnement_reminder
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("[Rappel]: RDV d'accompagnement dans le cadre de votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "En tant que bénéficiaire du RSA, vous avez reçu un premier mail il y a 3 jours vous invitant à prendre" \
        " rendez-vous afin de démarrer un parcours d’accompagnement."
      )
      expect(subject.body.encoded).to match("/invitations/redirect")
      expect(subject.body.encoded).to match("uuid=#{invitation.uuid}")
      expect(subject.body.encoded).to match(
        "Il ne vous reste plus que <span class=\"font-weight-bold\">#{invitation.number_of_days_before_expiration}" \
        " jours</span> pour prendre rendez-vous"
      )
    end
  end

  describe "#invitation_for_rsa_accompagnement_social_reminder" do
    subject do
      described_class.with(invitation: invitation, applicant: applicant)
                     .invitation_for_rsa_accompagnement_social_reminder
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("[Rappel]: RDV d'accompagnement dans le cadre de votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "En tant que bénéficiaire du RSA, vous avez reçu un premier mail il y a 3 jours vous invitant à prendre" \
        " rendez-vous afin de démarrer un parcours d’accompagnement."
      )
      expect(subject.body.encoded).to match("/invitations/redirect")
      expect(subject.body.encoded).to match("uuid=#{invitation.uuid}")
      expect(subject.body.encoded).to match(
        "Il ne vous reste plus que <span class=\"font-weight-bold\">#{invitation.number_of_days_before_expiration}" \
        " jours</span> pour prendre rendez-vous"
      )
    end
  end

  describe "#invitation_for_rsa_accompagnement_sociopro_reminder" do
    subject do
      described_class.with(invitation: invitation, applicant: applicant)
                     .invitation_for_rsa_accompagnement_sociopro_reminder
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("[Rappel]: RDV d'accompagnement dans le cadre de votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "En tant que bénéficiaire du RSA, vous avez reçu un premier mail il y a 3 jours vous invitant à prendre" \
        " rendez-vous afin de démarrer un parcours d’accompagnement."
      )
      expect(subject.body.encoded).to match("/invitations/redirect")
      expect(subject.body.encoded).to match("uuid=#{invitation.uuid}")
      expect(subject.body.encoded).to match(
        "Il ne vous reste plus que <span class=\"font-weight-bold\">#{invitation.number_of_days_before_expiration}" \
        " jours</span> pour prendre rendez-vous"
      )
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
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

  describe "#invitation_for_rsa_cer_signature_reminder" do
    subject do
      described_class
        .with(invitation: invitation, applicant: applicant)
        .invitation_for_rsa_cer_signature_reminder
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("[Rappel]: Votre RDV de signature de Contrat d'Engagement Réciproque" \
                                    " dans le cadre de votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "En tant que bénéficiaire du RSA, vous avez reçu un premier mail il y a 3 jours vous invitant à prendre" \
        " rendez-vous afin de construire et signer votre Contrat d'Engagement Réciproque."
      )
      expect(subject.body.encoded).to match("/invitations/redirect")
      expect(subject.body.encoded).to match("uuid=#{invitation.uuid}")
      expect(subject.body.encoded).to match(
        "Il ne vous reste plus que <span class=\"font-weight-bold\">#{invitation.number_of_days_before_expiration}" \
        " jours</span> pour prendre rendez-vous"
      )
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end
  end

  describe "#invitation_for_rsa_follow_up_reminder" do
    subject do
      described_class
        .with(invitation: invitation, applicant: applicant)
        .invitation_for_rsa_follow_up_reminder
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("[Rappel]: Votre RDV de suivi avec votre référent de parcours")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "En tant que bénéficiaire du RSA, vous avez reçu un premier mail il y a 3 jours vous invitant à" \
        " un rendez-vous de suivi."
      )
      expect(subject.body.encoded).to match("/invitations/redirect")
      expect(subject.body.encoded).to match("uuid=#{invitation.uuid}")
      expect(subject.body.encoded).to match(
        "Il ne vous reste plus que <span class=\"font-weight-bold\">#{invitation.number_of_days_before_expiration}" \
        " jours</span> pour prendre rendez-vous"
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
