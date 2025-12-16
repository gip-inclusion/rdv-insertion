describe Invitations::GenerateLetter, type: :service do
  subject do
    described_class.call(
      invitation: invitation
    )
  end

  include_context "with all existing categories"

  let!(:address) { "20 avenue de Segur, 75007 Paris" }
  let!(:user) { create(:user, organisations: [organisation], address: address, title: "monsieur") }
  let!(:department) { create(:department) }
  let!(:follow_up) { create(:follow_up, motif_category: category_rsa_orientation) }
  let!(:invitation) do
    create(
      :invitation, content: nil, user: user, organisations: [organisation],
                   department: department, format: "postal", follow_up: follow_up
    )
  end
  let!(:organisation) { create(:organisation, department: department) }
  let!(:messages_configuration) do
    create(:messages_configuration, organisation: organisation,
                                    direction_names: ["Direction départemental"], displayed_logos: [])
  end
  let!(:category_configuration) do
    create(:category_configuration, motif_category: category_rsa_orientation, organisation: organisation)
  end

  describe "#call" do
    it("is a success") { is_a_success }

    it "generates the pdf string with the invitation code" do
      subject
      content = strip_tags(invitation.content)
      expect(content).to include("20 AVENUE DE SEGUR")
      expect(content).to include("DIRECTION DÉPARTEMENTAL")
      expect(content).to include(
        " Pour vous aider dans vos démarches, " \
        "le Conseil départemental a mis en place une plateforme de prise de rendez-vous en ligne."
      )
      expect(content).to include(invitation.uuid)
      expect(content).to include(department.name)
      expect(content).to include(
        "Scanner ce QR code avec l'appareil photo de votre téléphone"
      )
      expect(content).to include("Vous êtes bénéficiaire du RSA")
      expect(content).not_to include("department-logo")
      expect(content).not_to include("europe-logos")
      expect(content).not_to include("france-travail-logo")
    end

    context "when user title is not provided" do
      before { user.update!(title: nil) }

      it "generates the pdf string without the user title" do
        subject
        expect(invitation.content).to include("Madame, Monsieur,")
      end
    end

    context "with signature image" do
      before do
        messages_configuration.signature_image.attach(
          io: File.open("spec/fixtures/logo.png"),
          filename: "signature.png",
          content_type: "image/png"
        )
      end

      it "includes signature image in generated letter" do
        subject
        content = unescape_html(invitation.content)

        expect(content).to include("signature.png")
        expect(content).to include("<img")
      end
    end

    context "when the format is not postal" do
      let!(:invitation) { create(:invitation, user: user, format: "sms") }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Génération d'une lettre alors que le format est sms"])
      end
    end

    context "when the address is blank" do
      let!(:address) { nil }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["L'adresse doit être renseignée"])
      end
    end

    context "when the address is invalid" do
      let!(:address) { "10 rue quincampoix" }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(
          [
            "Le format de l'adresse est invalide. Le format attendu est le suivant: 10 rue de l'envoi 12345 - La Ville"
          ]
        )
      end
    end

    context "when the signature is configured" do
      let!(:messages_configuration) do
        create(:messages_configuration, organisation: organisation, signature_lines: ["Fabienne Bouchet"])
      end

      it "generates the pdf string with the right signature" do
        subject
        expect(invitation.content).to include("Fabienne Bouchet")
      end
    end

    context "when the department logo is configured to be displayed" do
      let!(:messages_configuration) do
        create(:messages_configuration, organisation: organisation, displayed_logos: %w[department])
      end

      it "generates the pdf string with the department logo" do
        subject
        expect(invitation.content).to include("department-logo")
      end
    end

    context "when the europe logos are configured to be displayed" do
      let!(:messages_configuration) do
        create(:messages_configuration, organisation: organisation, displayed_logos: %w[europe])
      end

      it "generates the pdf string with the europe logos" do
        subject
        expect(invitation.content).to include("europe-logos")
      end
    end

    context "when the pole emploi logo is configured to be displayed" do
      let!(:messages_configuration) do
        create(:messages_configuration, organisation: organisation, displayed_logos: %w[france_travail])
      end

      it "generates the pdf string with the pole emploi logo" do
        subject
        expect(invitation.content).to include("france-travail-logo")
      end
    end

    context "when the help address is configured" do
      let!(:messages_configuration) do
        create(:messages_configuration, organisation: organisation,
                                        help_address: "10, rue du Conseil départemental 75001 Paris")
      end

      it "renders the mail with the help address" do
        subject
        expect(invitation.content).to include("10, rue du Conseil départemental 75001 Paris")
      end
    end

    context "when the invitation is not in a referent context" do
      it "generates the pdf with no reference to a referent" do
        subject
        expect(invitation.content).not_to include("Référent de parcours")
      end
    end

    context "when the invitation is in a referent context and the user has a referent" do
      let!(:invitation) do
        create(
          :invitation, content: nil, user: user, organisations: [organisation],
                       department: department, format: "postal", follow_up: follow_up, rdv_with_referents: true
        )
      end
      let!(:agent) do
        create(:agent, organisations: [organisation], users: [user],
                       first_name: "Kylian", last_name: "Mbappé")
      end

      it "displays the name of the referent" do
        subject
        expect(invitation.content).to include("Référent de parcours : Kylian MBAPPÉ")
      end
    end

    context "when the context is orientation" do
      let!(:follow_up) { create(:follow_up, motif_category: category_rsa_orientation) }

      it "generates the pdf with the right content" do
        subject
        content = strip_tags(invitation.content)
        expect(content).to include("Objet : Rendez-vous d'orientation dans le cadre de votre RSA")
        expect(content).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes invité à participer " \
          "à un rendez-vous d'orientation pour démarrer " \
          "un parcours d'accompagnement"
        )
        expect(content).to include(
          "Choisissez un rendez-vous dans un délai de 3 jours à compter de la réception de ce courrier."
        )
        expect(content).to include("Pour choisir la date et l'heure de votre rendez-vous, vous pouvez")
        expect(content).to include("Ce rendez-vous est obligatoire.")
        expect(content).not_to include(
          "En l'absence d'action de votre part, votre RSA pourra être suspendu ou réduit."
        )
      end

      context "when the template attributes are overriden by the category_configuration attributes" do
        before do
          category_configuration.update!(
            template_rdv_title_override: "nouveau type de rendez-vous",
            template_rdv_purpose_override: "démarrer un test fonctionnel"
          )
        end

        it "generates the pdf with the overriden content" do
          subject
          content = strip_tags(invitation.content)
          expect(content).to include("Objet : Nouveau type de rendez-vous dans le cadre de votre RSA")
          expect(content).to include(
            "Vous êtes bénéficiaire du RSA et à ce titre vous êtes invité à participer à un " \
            "nouveau type de rendez-vous pour démarrer un test fonctionnel"
          )
          expect(content).to include(
            "Choisissez un rendez-vous dans un délai de 3 jours à compter de la réception de ce courrier."
          )
          expect(content).to include("Pour choisir la date et l'heure de votre rendez-vous, vous pouvez")
          expect(content).to include("Ce rendez-vous est obligatoire.")
          expect(content).not_to include(
            "En l'absence d'action de votre part, votre RSA pourra être suspendu ou réduit."
          )
        end
      end
    end

    context "when the context is orientation_france_travail" do
      let!(:follow_up) { create(:follow_up, motif_category: category_rsa_orientation_france_travail) }

      it "generates the pdf with the right content" do
        subject
        content = strip_tags(invitation.content)
        expect(content).to include(
          "Objet : Rendez-vous d'orientation dans le cadre de votre RSA"
        )
        expect(content).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes invité à participer " \
          "à un rendez-vous d'orientation pour démarrer un parcours d'accompagnement."
        )
        expect(content).to include(
          "Dans le cadre du projet 'France Travail', ce rendez-vous sera réalisé par deux"
        )
        expect(content).to include(
          "Choisissez un rendez-vous dans un délai de 3 jours à compter de la réception de ce courrier."
        )
        expect(content).to include("Pour choisir la date et l'heure de votre rendez-vous, vous pouvez")
        expect(content).to include("Ce rendez-vous est obligatoire.")
        expect(content).not_to include(
          "En l'absence d'action de votre part, votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "when the context is accompagnement" do
      let!(:follow_up) { create(:follow_up, motif_category: category_rsa_accompagnement) }

      it "generates the pdf with the right content" do
        subject
        content = strip_tags(invitation.content)
        expect(content).to include("Objet : Rendez-vous d'accompagnement dans le cadre de votre RSA")
        expect(content).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes invité à participer " \
          "à un rendez-vous d'accompagnement " \
          "pour démarrer un parcours d'accompagnement"
        )
        expect(content).to include(
          "Choisissez un rendez-vous dans un délai de 3 jours à compter de la réception de ce courrier."
        )
        expect(content).to include("Pour choisir la date et l'heure de votre rendez-vous, vous pouvez")
        expect(content).to include("Ce rendez-vous est obligatoire.")
        expect(content).to include(
          "En l'absence d'action de votre part, votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "when the context is rsa_cer_signature" do
      let!(:follow_up) { create(:follow_up, motif_category: category_rsa_cer_signature) }

      it "generates the pdf with the right content" do
        subject
        content = strip_tags(invitation.content)
        expect(content).to include(
          "Objet : Rendez-vous de signature de CER dans le cadre de votre RSA"
        )
        expect(content).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes invité à participer " \
          "à un rendez-vous de signature de CER " \
          "pour construire et signer votre Contrat d'Engagement Réciproque"
        )
        expect(content).to include(
          "Choisissez un rendez-vous dans un délai de 3 jours à compter de la réception de ce courrier."
        )
        expect(content).to include("Pour choisir la date et l'heure de votre rendez-vous, vous pouvez")
        expect(content).to include("Ce rendez-vous est obligatoire.")
        expect(content).not_to include(
          "En l'absence d'action de votre part, votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "when the context is rsa_follow_up" do
      let!(:follow_up) { create(:follow_up, motif_category: category_rsa_follow_up) }

      it "generates the pdf with the right content" do
        subject
        content = strip_tags(invitation.content)
        expect(content).to include(
          "Objet : Rendez-vous de suivi dans le cadre de votre RSA"
        )
        expect(content).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes invité à participer " \
          "à un rendez-vous de suivi pour faire un point " \
          "avec votre référent de parcours"
        )
        expect(content).to include(
          "Choisissez un rendez-vous dans un délai de 3 jours à compter de la réception de ce courrier."
        )
        expect(content).to include("Pour choisir la date et l'heure de votre rendez-vous, vous pouvez")
        expect(content).not_to include("Ce rendez-vous est obligatoire.")
        expect(content).not_to include(
          "En l'absence d'action de votre part, votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "when the context is siae_interview" do
      let!(:follow_up) { create(:follow_up, motif_category: category_siae_interview) }

      it "generates the pdf with the right content" do
        subject
        content = strip_tags(invitation.content)
        expect(content).to include(
          "Objet : Entretien d'embauche dans le cadre de votre candidature SIAE"
        )
        expect(content).to include(
          "Vous êtes candidat.e dans une Structure d’Insertion par l’Activité Economique (SIAE) " \
          "et à ce titre vous êtes invité " \
          "à participer à un entretien d'embauche pour " \
          "poursuivre le processus de recrutement"
        )
        expect(content).to include(
          "Choisissez un rendez-vous dans un délai de 3 jours à compter de la réception de ce courrier."
        )
        expect(content).to include("Pour choisir la date et l'heure de votre rendez-vous, vous pouvez")
        expect(content).not_to include("N° usager.")
        expect(content).not_to include("Ce rendez-vous est obligatoire.")
        expect(content).not_to include(
          "En l'absence d'action de votre part, votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "when the context is siae_follow_up" do
      let!(:follow_up) { create(:follow_up, motif_category: category_siae_follow_up) }

      it "generates the pdf with the right content" do
        subject
        content = strip_tags(invitation.content)
        expect(content).to include(
          "Objet : Rendez-vous de suivi dans le cadre de votre suivi SIAE"
        )
        expect(content).to include(
          "Vous êtes salarié.e au sein de notre structure et à ce titre vous " \
          "êtes invité à participer à un rendez-vous de suivi pour faire un point " \
          "avec votre référent"
        )
        expect(content).to include(
          "Choisissez un rendez-vous dans un délai de 3 jours à compter de la réception de ce courrier."
        )
        expect(content).to include("Pour choisir la date et l'heure de votre rendez-vous, vous pouvez")
        expect(content).not_to include("N° usager.")
        expect(content).not_to include("Ce rendez-vous est obligatoire.")
        expect(content).not_to include(
          "En l'absence d'action de votre part, votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "when the context is siae_collective_information" do
      let!(:follow_up) { create(:follow_up, motif_category: category_siae_collective_information) }

      it "generates the pdf with the right content" do
        subject
        content = strip_tags(invitation.content)
        expect(content).to include(
          "Objet : Rendez-vous collectif d'information dans le cadre de votre candidature SIAE"
        )
        expect(content).to include(
          "Vous êtes candidat.e dans une Structure d’Insertion par l’Activité Economique (SIAE) et " \
          "à ce titre vous êtes invité " \
          "à participer à un rendez-vous collectif d'information pour " \
          "découvrir cette structure"
        )
        expect(content).to include(
          "Choisissez un rendez-vous dans un délai de 3 jours à compter de la réception de ce courrier."
        )
        expect(content).to include("Pour choisir la date et l'heure de votre rendez-vous, vous pouvez")
        expect(content).not_to include("N° usager.")
        expect(content).not_to include("Ce rendez-vous est obligatoire.")
        expect(content).not_to include(
          "En l'absence d'action de votre part, votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "when the context is rsa_insertion_offer" do
      let!(:follow_up) { create(:follow_up, motif_category: category_rsa_insertion_offer) }

      it "generates the pdf with the right content" do
        subject
        content = strip_tags(invitation.content)
        expect(content).to include(
          "Objet : Participation à un atelier dans le cadre de votre RSA"
        )
        expect(content).to include(
          "Vous êtes bénéficiaire du RSA et bénéficiez d'un accompagnement. " \
          "Pour en profiter au mieux, nous vous invitons à vous inscrire directement " \
          "et librement aux ateliers et formations de votre choix."
        )
        expect(content).not_to include(
          "Choisissez un rendez-vous dans un délai de 3 jours à compter de la réception de ce courrier."
        )
        expect(content).to include("Choisissez un créneau à votre convenance")
        expect(content).not_to include("Ce rendez-vous est obligatoire.")
        expect(content).not_to include(
          "En l'absence d'action de votre part, votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "when the context is rsa_atelier_competences" do
      let!(:follow_up) { create(:follow_up, motif_category: category_rsa_atelier_competences) }

      it "generates the pdf with the right content" do
        subject
        content = strip_tags(invitation.content)
        expect(content).to include(
          "Objet : Participation à un atelier dans le cadre de votre RSA"
        )
        expect(content).to include(
          "Vous êtes bénéficiaire du RSA et bénéficiez d'un accompagnement. " \
          "Pour en profiter au mieux, nous vous invitons à vous inscrire directement " \
          "et librement aux ateliers et formations de votre choix."
        )
        expect(content).to include("Choisissez un créneau à votre convenance")
        expect(content).not_to include(
          "Choisissez un rendez-vous dans un délai de 3 jours à compter de la réception de ce courrier."
        )
        expect(content).not_to include("Vous devez obligatoirement prendre ce rendez-vous")
        expect(content).not_to include(
          "En l'absence d'action de votre part, vous risquez une suspension ou réduction du versement de votre RSA."
        )
      end
    end

    context "when the context is rsa_atelier_rencontres_pro" do
      let!(:follow_up) { create(:follow_up, motif_category: category_rsa_atelier_rencontres_pro) }

      it "generates the pdf with the right content" do
        subject
        content = strip_tags(invitation.content)
        expect(content).to include(
          "Objet : Participation à un atelier dans le cadre de votre RSA"
        )
        expect(content).to include(
          "Vous êtes bénéficiaire du RSA et bénéficiez d'un accompagnement. " \
          "Pour en profiter au mieux, nous vous invitons à vous inscrire directement " \
          "et librement aux ateliers et formations de votre choix."
        )
        expect(content).to include("Choisissez un créneau à votre convenance")
        expect(content).not_to include(
          "Choisissez un rendez-vous dans un délai de 3 jours à compter de la réception de ce courrier."
        )
        expect(content).not_to include(
          "En l'absence d'action de votre part, votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "when the context is rsa_orientation_on_phone_platform" do
      let!(:follow_up) { create(:follow_up, motif_category: category_rsa_orientation_on_phone_platform) }

      it "generates the pdf with the right content" do
        subject
        content = strip_tags(invitation.content)
        expect(content).to include(
          "Objet : Rendez-vous d’orientation dans le cadre de votre RSA"
        )
        expect(content).to include(
          "La première étape est un appel téléphonique avec un professionnel de l’insertion " \
          "afin de définir, selon votre situation et vos besoins, quelle sera la structure " \
          "la mieux adaptée pour vous accompagner."
        )
        expect(content).to include("Cet appel est obligatoire pour le traitement de votre dossier.")
        expect(content).to include(
          "Pour cela, merci d’appeler le 0139393939 dans un délai de 3 jours " \
          "à compter de la réception de ce courrier."
        )
      end
    end

    context "when the context is atelier_enfants_ados" do
      let!(:follow_up) { create(:follow_up, motif_category: category_atelier_enfants_ados) }

      it "generates the pdf with the right content" do
        subject
        content = strip_tags(invitation.content)
        expect(content).to include(
          "Objet : Participation à un atelier"
        )
        expect(content).to include(
          "Tu es invité à participer à un atelier organisé par le département."
        )
        expect(content).to include(
          "Nous te proposons de découvrir le programme."
        )
      end
    end
  end
end
