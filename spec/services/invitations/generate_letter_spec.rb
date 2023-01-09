describe Invitations::GenerateLetter, type: :service do
  subject do
    described_class.call(
      invitation: invitation
    )
  end

  let!(:applicant) { create(:applicant, organisations: [organisation]) }
  let!(:department) { create(:department) }
  let!(:rdv_context) { create(:rdv_context) }
  let!(:invitation) do
    create(
      :invitation, content: nil, applicant: applicant, organisations: [organisation],
                   department: department, format: "postal", rdv_context: rdv_context
    )
  end
  let!(:messages_configuration) { create(:messages_configuration) }
  let!(:organisation) do
    create(:organisation, messages_configuration: messages_configuration,
                          department: department)
  end

  describe "#call" do
    it("is a success") { is_a_success }

    it "generates the pdf string with the invitation code" do
      subject
      content = unescape_html(invitation.content)
      expect(content).to include("Pour choisir un créneau à votre convenance, saisissez le code d’invitation")
      expect(content).to include(invitation.uuid)
      expect(content).to include(department.name)
      expect(content).to include("Vous êtes allocataire du Revenu de Solidarité Active (RSA)")
      # letter-first-col is only used when display_europe_logos is true (false by default)
      expect(content).not_to include("letter-first-col")
    end

    context "when the signature is configured" do
      let!(:messages_configuration) { create(:messages_configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "generates the pdf string with the right signature" do
        subject
        expect(invitation.content).to include("Fabienne Bouchet")
      end
    end

    context "when the europe logos are configured to be displayed" do
      let!(:messages_configuration) { create(:messages_configuration, display_europe_logos: true) }

      it "generates the pdf string with the europe logos" do
        subject
        # letter-first-col is only used when display_europe_logos is true
        expect(invitation.content).to include("letter-first-col")
      end
    end

    context "when the help address is configured" do
      let!(:messages_configuration) do
        create(:messages_configuration, help_address: "10, rue du Conseil départemental 75001 Paris")
      end

      it "renders the mail with the help address" do
        subject
        expect(invitation.content).to include("10, rue du Conseil départemental 75001 Paris")
      end
    end

    context "when the context is orientation" do
      let!(:rdv_context) { create(:rdv_context, motif_category: "rsa_orientation") }

      it "generates the pdf with the right content" do
        subject
        content = unescape_html(invitation.content)
        expect(content).to include("Objet : Rendez-vous d'orientation dans le cadre de votre RSA")
        expect(content).to include("vous devez prendre un rendez-vous afin de démarrer un parcours d'accompagnement")
        expect(content).to include("Vous devez obligatoirement prendre ce rendez-vous")
        expect(content).not_to include(
          "En l'absence d'action de votre part, vous risquez une suspension ou réduction du versement de votre RSA."
        )
      end
    end

    context "when the context is accompagnement" do
      let!(:rdv_context) { create(:rdv_context, motif_category: "rsa_accompagnement") }

      it "generates the pdf with the right content" do
        subject
        content = unescape_html(invitation.content)
        expect(content).to include("Objet : Rendez-vous d'accompagnement dans le cadre de votre RSA")
        expect(content).to include("vous devez prendre un rendez-vous afin de démarrer un parcours d'accompagnement")
        expect(content).to include("Vous devez obligatoirement prendre ce rendez-vous")
        expect(content).to include(
          "En l'absence d'action de votre part, vous risquez une suspension ou réduction du versement de votre RSA."
        )
      end
    end

    context "when the context is rsa_cer_signature" do
      let!(:rdv_context) { create(:rdv_context, motif_category: "rsa_cer_signature") }

      it "generates the pdf with the right content" do
        subject
        content = unescape_html(invitation.content)
        expect(content).to include(
          "Objet : Rendez-vous de signature de CER dans le cadre de votre RSA"
        )
        expect(content).to include(
          "vous devez prendre un rendez-vous afin de construire et signer votre Contrat d'Engagement Réciproque"
        )
        expect(content).to include("Vous devez obligatoirement prendre ce rendez-vous")
        expect(content).not_to include(
          "En l'absence d'action de votre part, vous risquez une suspension ou réduction du versement de votre RSA."
        )
      end
    end

    context "when the context is rsa_follow_up" do
      let!(:rdv_context) { create(:rdv_context, motif_category: "rsa_follow_up") }

      it "generates the pdf with the right content" do
        subject
        content = unescape_html(invitation.content)
        expect(content).to include(
          "Objet : Rendez-vous de suivi dans le cadre de votre RSA"
        )
        expect(content).to include(
          "vous devez prendre un rendez-vous afin de faire un point avec votre référent de parcours"
        )
        expect(content).not_to include("Vous devez obligatoirement prendre ce rendez-vous")
        expect(content).not_to include(
          "En l'absence d'action de votre part, vous risquez une suspension ou réduction du versement de votre RSA."
        )
      end
    end

    context "when the context is rsa_insertion_offer" do
      let!(:rdv_context) { create(:rdv_context, motif_category: "rsa_insertion_offer") }

      it "generates the pdf with the right content" do
        subject
        content = unescape_html(invitation.content)
        expect(content).to include(
          "Objet : Offre d'insertion dans le cadre de votre RSA"
        )
        expect(content).to include(
          "Pour profiter au mieux de cet accompagnement, nous vous invitons à vous inscrire directement" \
          " et librement aux ateliers et formations de votre choix"
        )
        expect(content).not_to include("Vous devez obligatoirement prendre ce rendez-vous")
        expect(content).not_to include(
          "En l'absence d'action de votre part, vous risquez une suspension ou réduction du versement de votre RSA."
        )
      end
    end

    context "when the context is rsa_orientation_on_phone_platform" do
      let!(:rdv_context) { create(:rdv_context, motif_category: "rsa_orientation_on_phone_platform") }

      it "generates the pdf with the right content" do
        subject
        content = unescape_html(invitation.content)
        expect(content).to include(
          "Objet : Rendez-vous d’orientation dans le cadre de votre RSA"
        )
        expect(content).to include(
          "La première étape est <span class=\"bold-blue\">un appel téléphonique avec un professionnel de l’insertion" \
          "</span> afin de définir, selon votre situation et vos besoins, quelle sera la structure la " \
          "mieux adaptée pour vous accompagner."
        )
        expect(content).to include("Cet appel est obligatoire dans le cadre du versement de votre allocation RSA")
      end
    end

    context "when the format is not postal" do
      let!(:invitation) { create(:invitation, applicant: applicant, format: "sms") }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Génération d'une lettre alors que le format est sms"])
      end
    end

    context "when the address is blank" do
      let!(:applicant) { create(:applicant, address: nil) }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["L'adresse doit être renseignée"])
      end
    end

    context "when the address is invalid" do
      let!(:applicant) { create(:applicant, :skip_validate, address: "10 rue") }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Le format de l'adresse est invalide"])
      end
    end
  end
end
