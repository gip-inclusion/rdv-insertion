RSpec.describe NotificationMailer do
  include_context "with all existing categories"

  let!(:notification) { create(:notification, participation: participation) }
  let!(:participation) { create(:participation, applicant: applicant, rdv: rdv, rdv_context: rdv_context) }
  let!(:applicant) { create(:applicant, email: "someone@gmail.com", title: "monsieur", phone_number: "0607070707") }
  let!(:rdv) do
    create(
      :rdv,
      lieu: lieu, starts_at: Time.zone.parse("20/12/2021 12:00"), organisation: organisation
    )
  end
  let!(:organisation) { create(:organisation, messages_configuration: messages_configuration) }
  let!(:messages_configuration) { create(:messages_configuration, signature_lines: signature_lines) }
  let!(:lieu) { create(:lieu, name: "DINUM", address: "20 avenue de ségur 75007 Paris", phone_number: "0101010101") }
  let!(:signature_lines) { ["Signé par la DINUM"] }
  let!(:rdv_context) { create(:rdv_context, motif_category: motif_category) }
  let!(:motif_category) { category_rsa_orientation }

  describe "#presential_participation_created" do
    let!(:mail) do
      described_class.with(notification: notification).presential_participation_created
    end

    it "renders the headers" do
      expect(mail[:from].to_s).to eq("RDV-Insertion <contact@rdv-insertion.fr>")
      expect(mail.to).to eq(["someone@gmail.com"])
    end

    it "renders the signature" do
      expect(mail.body.encoded).to match("Signé par la DINUM")
    end

    context "for rsa orientation" do
      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué à un rendez-vous d'orientation"
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes convoqué à un rendez-vous d'orientation"
        )
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("DINUM")
        expect(body_string).to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end

      context "when the applicant is a woman" do
        before { applicant.title = "madame" }

        it "renders the subject" do
          expect(mail.subject).to eq(
            "[Important - RSA] Vous êtes convoquée à un rendez-vous d'orientation"
          )
        end

        it "renders the body" do
          body_string = unescape_html(mail.body.encoded)
          expect(body_string).to include(
            "Vous êtes bénéficiaire du RSA et à ce titre vous êtes convoquée à un rendez-vous d'orientation"
          )
        end
      end
    end

    context "for rsa accompagnement" do
      let!(:motif_category) { category_rsa_accompagnement }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué à un rendez-vous d'accompagnement"
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes convoqué à un rendez-vous d'accompagnement"
        )
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("DINUM")
        expect(body_string).to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnement social" do
      let!(:motif_category) { category_rsa_accompagnement_social }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué à un rendez-vous d'accompagnement"
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes convoqué à un rendez-vous d'accompagnement"
        )
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("DINUM")
        expect(body_string).to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnement sociopro" do
      let!(:motif_category) { category_rsa_accompagnement_sociopro }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué à un rendez-vous d'accompagnement"
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes convoqué à un rendez-vous d'accompagnement"
        )
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("DINUM")
        expect(body_string).to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa cer signature" do
      let!(:motif_category) { category_rsa_cer_signature }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué à un rendez-vous de signature de CER"
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes convoqué à un rendez-vous de signature de CER" \
          " afin de construire et signer votre Contrat d'Engagement Réciproque"
        )
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("DINUM")
        expect(body_string).to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa follow up" do
      let!(:motif_category) { category_rsa_follow_up }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué à un rendez-vous de suivi"
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes convoqué à un rendez-vous de suivi" \
          " afin de faire un point avec votre référent de parcours"
        )
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("DINUM")
        expect(body_string).to include("20 avenue de ségur 75007 Paris")
        expect(body_string).not_to include("Ce rendez-vous est obligatoire")
        expect(body_string).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end
  end

  describe "#presential_participation_updated" do
    let!(:mail) do
      described_class.with(notification: notification).presential_participation_updated
    end

    it "renders the headers" do
      expect(mail[:from].to_s).to eq("RDV-Insertion <contact@rdv-insertion.fr>")
      expect(mail.to).to eq(["someone@gmail.com"])
    end

    it "renders the signature" do
      expect(mail.body.encoded).to match("Signé par la DINUM")
    end

    context "for rsa orientation" do
      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'orientation a été modifié."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous d'orientation dans le cadre de votre RSA a été modifié"
        )
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("DINUM")
        expect(body_string).to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnement" do
      let!(:motif_category) { category_rsa_accompagnement }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'accompagnement a été modifié."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous d'accompagnement dans le cadre de votre RSA a été modifié"
        )
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("DINUM")
        expect(body_string).to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnemen social" do
      let!(:motif_category) { category_rsa_accompagnement_social }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'accompagnement a été modifié."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous d'accompagnement dans le cadre de votre RSA a été modifié"
        )
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("DINUM")
        expect(body_string).to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnement sociopro" do
      let!(:motif_category) { category_rsa_accompagnement_sociopro }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'accompagnement a été modifié."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous d'accompagnement dans le cadre de votre RSA a été modifié"
        )
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("DINUM")
        expect(body_string).to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa cer signature" do
      let!(:motif_category) { category_rsa_cer_signature }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous de signature de CER a été modifié."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous de signature de CER" \
          " dans le cadre de votre RSA a été modifié."
        )
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("DINUM")
        expect(body_string).to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa follow up" do
      let!(:motif_category) { category_rsa_follow_up }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous de suivi a été modifié."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous de suivi dans le cadre de votre RSA a été modifié"
        )
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("DINUM")
        expect(body_string).to include("20 avenue de ségur 75007 Paris")
        expect(body_string).not_to include("Ce rendez-vous est obligatoire")
        expect(body_string).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end
  end

  describe "#by_phone_participation_created" do
    let!(:mail) do
      described_class.with(notification: notification).by_phone_participation_created
    end

    it "renders the headers" do
      expect(mail[:from].to_s).to eq("RDV-Insertion <contact@rdv-insertion.fr>")
      expect(mail.to).to eq(["someone@gmail.com"])
    end

    it "renders the signature" do
      expect(mail.body.encoded).to match("Signé par la DINUM")
    end

    context "for rsa orientation" do
      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué à un rendez-vous d'orientation téléphonique"
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes convoqué à un rendez-vous d'orientation" \
          " téléphonique afin de démarrer un parcours d'accompagnement"
        )
        expect(body_string).to include("Un travailleur social vous appellera")
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("sur votre numéro de téléphone:")
        expect(body_string).to include("+33607070707")
        expect(body_string).not_to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnement" do
      let!(:motif_category) { category_rsa_accompagnement }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué à un rendez-vous d'accompagnement téléphonique"
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes convoqué " \
          "à un rendez-vous d'accompagnement téléphonique afin de démarrer un parcours d'accompagnement"
        )
        expect(body_string).to include("Un travailleur social vous appellera")
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("sur votre numéro de téléphone:")
        expect(body_string).to include("+33607070707")
        expect(body_string).not_to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnement social" do
      let!(:motif_category) { category_rsa_accompagnement_social }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué à un rendez-vous d'accompagnement téléphonique"
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes convoqué " \
          "à un rendez-vous d'accompagnement téléphonique afin de démarrer un parcours d'accompagnement"
        )
        expect(body_string).to include("Un travailleur social vous appellera")
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("sur votre numéro de téléphone:")
        expect(body_string).to include("+33607070707")
        expect(body_string).not_to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnement sociopro" do
      let!(:motif_category) { category_rsa_accompagnement_sociopro }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué à un rendez-vous d'accompagnement téléphonique"
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes convoqué " \
          "à un rendez-vous d'accompagnement téléphonique afin de démarrer un parcours d'accompagnement"
        )
        expect(body_string).to include("Un travailleur social vous appellera")
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("sur votre numéro de téléphone:")
        expect(body_string).to include("+33607070707")
        expect(body_string).not_to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa cer signature" do
      let!(:motif_category) { category_rsa_cer_signature }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué à un rendez-vous téléphonique de signature de CER"
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes convoqué à un rendez-vous téléphonique" \
          " de signature de CER afin de construire et signer votre Contrat d'Engagement Réciproque"
        )
        expect(body_string).to include("Un travailleur social vous appellera")
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("sur votre numéro de téléphone:")
        expect(body_string).to include("+33607070707")
        expect(body_string).not_to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa follow up" do
      let!(:motif_category) { category_rsa_follow_up }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué à un rendez-vous de suivi téléphonique"
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous êtes convoqué à un rendez-vous de suivi " \
          "téléphonique afin de faire un point avec votre référent de parcours" \
        )
        expect(body_string).to include("Un travailleur social vous appellera")
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("sur votre numéro de téléphone:")
        expect(body_string).to include("+33607070707")
        expect(body_string).not_to include("20 avenue de ségur 75007 Paris")
        expect(body_string).not_to include("Ce rendez-vous est obligatoire")
        expect(body_string).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "when applicant does not have a phone number" do
      let!(:applicant) { create(:applicant, email: "someone@gmail.com", phone_number: nil) }

      it "raises an error" do
        expect { mail.deliver_now }.to raise_error(
          NotificationMailerError,
          "No valid phone found for applicant #{applicant.id}, cannot notify him by phone"
        )
      end
    end
  end

  describe "#by_phone_participation_updated" do
    let!(:mail) do
      described_class.with(notification: notification).by_phone_participation_updated
    end

    it "renders the headers" do
      expect(mail[:from].to_s).to eq("RDV-Insertion <contact@rdv-insertion.fr>")
      expect(mail.to).to eq(["someone@gmail.com"])
    end

    it "renders the signature" do
      expect(mail.body.encoded).to match("Signé par la DINUM")
    end

    context "for rsa orientation" do
      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'orientation téléphonique a été modifié."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous d'orientation téléphonique dans le cadre de votre RSA a été modifié."
        )
        expect(body_string).to include("Un travailleur social vous appellera")
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("sur votre numéro de téléphone:")
        expect(body_string).to include("+33607070707")
        expect(body_string).not_to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnement" do
      let!(:motif_category) { category_rsa_accompagnement }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'accompagnement téléphonique a été modifié."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous d'accompagnement téléphonique dans le cadre de votre RSA a été modifié."
        )
        expect(body_string).to include("Un travailleur social vous appellera")
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("sur votre numéro de téléphone:")
        expect(body_string).to include("+33607070707")
        expect(body_string).not_to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnement social" do
      let!(:motif_category) { category_rsa_accompagnement_social }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'accompagnement téléphonique a été modifié."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous d'accompagnement téléphonique dans le cadre de votre RSA a été modifié."
        )
        expect(body_string).to include("Un travailleur social vous appellera")
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("sur votre numéro de téléphone:")
        expect(body_string).to include("+33607070707")
        expect(body_string).not_to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnement sociopro" do
      let!(:motif_category) { category_rsa_accompagnement_sociopro }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'accompagnement téléphonique a été modifié."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous d'accompagnement téléphonique dans le cadre de votre RSA a été modifié."
        )
        expect(body_string).to include("Un travailleur social vous appellera")
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("sur votre numéro de téléphone:")
        expect(body_string).to include("+33607070707")
        expect(body_string).not_to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa cer signature" do
      let!(:motif_category) { category_rsa_cer_signature }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous téléphonique de signature de CER a été modifié."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous téléphonique de signature de CER" \
          " dans le cadre de votre RSA a été modifié"
        )
        expect(body_string).to include("Un travailleur social vous appellera")
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("sur votre numéro de téléphone:")
        expect(body_string).to include("+33607070707")
        expect(body_string).not_to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa follow up" do
      let!(:motif_category) { category_rsa_follow_up }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous de suivi téléphonique a été modifié."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous de suivi " \
          "téléphonique dans le cadre de votre RSA a été modifié" \
        )
        expect(body_string).to include("Un travailleur social vous appellera")
        expect(body_string).to include("le lundi 20 décembre 2021 à 12h00")
        expect(body_string).to include("sur votre numéro de téléphone:")
        expect(body_string).to include("+33607070707")
        expect(body_string).not_to include("20 avenue de ségur 75007 Paris")
        expect(body_string).not_to include("Ce rendez-vous est obligatoire")
        expect(body_string).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "when applicant does not have a phone number" do
      let!(:applicant) { create(:applicant, email: "someone@gmail.com", phone_number: nil) }

      it "raises an error" do
        expect { mail.deliver_now }.to raise_error(
          NotificationMailerError,
          "No valid phone found for applicant #{applicant.id}, cannot notify him by phone"
        )
      end
    end
  end

  describe "#participation_cancelled" do
    let!(:mail) do
      described_class.with(notification: notification).participation_cancelled
    end

    it "renders the headers" do
      expect(mail[:from].to_s).to eq("RDV-Insertion <contact@rdv-insertion.fr>")
      expect(mail.to).to eq(["someone@gmail.com"])
    end

    it "renders the signature" do
      expect(mail.body.encoded).to match("Signé par la DINUM")
    end

    context "for rsa orientation" do
      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'orientation a été annulé."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous d'orientation dans le cadre de votre RSA initialement prévu " \
          "le lundi 20 décembre 2021 à 12h00 a été annulé."
        )
        expect(body_string).to include("Pour plus d'informations, veuillez appeler le 0101010101")
      end
    end

    context "for rsa accompagnement" do
      let!(:motif_category) { category_rsa_accompagnement }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'accompagnement a été annulé."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous d'accompagnement dans le cadre de votre RSA initialement prévu " \
          "le lundi 20 décembre 2021 à 12h00 a été annulé."
        )
        expect(body_string).to include("Pour plus d'informations, veuillez appeler le 0101010101")
      end
    end

    context "for rsa accompagnement social" do
      let!(:motif_category) { category_rsa_accompagnement_social }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'accompagnement a été annulé."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous d'accompagnement dans le cadre de votre RSA initialement prévu " \
          "le lundi 20 décembre 2021 à 12h00 a été annulé."
        )
        expect(body_string).to include("Pour plus d'informations, veuillez appeler le 0101010101")
      end
    end

    context "for rsa accompagnement sociopro" do
      let!(:motif_category) { category_rsa_accompagnement_sociopro }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'accompagnement a été annulé."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous d'accompagnement dans le cadre de votre RSA initialement prévu " \
          "le lundi 20 décembre 2021 à 12h00 a été annulé."
        )
        expect(body_string).to include("Pour plus d'informations, veuillez appeler le 0101010101")
      end
    end

    context "for rsa cer signature" do
      let!(:motif_category) { category_rsa_cer_signature }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous de signature de CER a été annulé."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous de signature de CER" \
          " dans le cadre de votre RSA initialement prévu " \
          "le lundi 20 décembre 2021 à 12h00 a été annulé."
        )
        expect(body_string).to include("Pour plus d'informations, veuillez appeler le 0101010101")
      end
    end

    context "for rsa follow up" do
      let!(:motif_category) { category_rsa_follow_up }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous de suivi a été annulé."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Votre rendez-vous de suivi dans le cadre de votre RSA initialement prévu " \
          "le lundi 20 décembre 2021 à 12h00 a été annulé."
        )
        expect(body_string).to include("Pour plus d'informations, veuillez appeler le 0101010101")
      end
    end
  end

  describe "#presential_participation_reminder" do
    let!(:mail) do
      described_class.with(notification: notification).presential_participation_reminder
    end

    it "renders the headers" do
      expect(mail[:from].to_s).to eq("RDV-Insertion <contact@rdv-insertion.fr>")
      expect(mail.to).to eq(["someone@gmail.com"])
    end

    it "renders the signature" do
      expect(mail.body.encoded).to match("Signé par la DINUM")
    end

    context "for rsa orientation" do
      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Rappel - RSA] Vous êtes convoqué(e) à un rendez-vous d'orientation."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un rendez-vous d'orientation"
        )
        expect(body_string).to include("Nous vous rappelons que vous êtes attendu(e)")
        expect(body_string).to include("le 20/12/2021 à 12:00")
        expect(body_string).to include("DINUM")
        expect(body_string).to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end
  end

  describe "#by_phone_participation_reminder" do
    let!(:mail) do
      described_class.with(notification: notification).by_phone_participation_reminder
    end

    it "renders the headers" do
      expect(mail[:from].to_s).to eq("RDV-Insertion <contact@rdv-insertion.fr>")
      expect(mail.to).to eq(["someone@gmail.com"])
    end

    it "renders the signature" do
      expect(mail.body.encoded).to match("Signé par la DINUM")
    end

    context "for rsa orientation" do
      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Rappel - RSA] Vous êtes convoqué(e) à un rendez-vous d'orientation téléphonique."
        )
      end

      it "renders the body" do
        body_string = unescape_html(mail.body.encoded)
        expect(body_string).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un rendez-vous d'orientation" \
          " téléphonique afin de démarrer un parcours d'accompagnement"
        )
        expect(body_string).to include("Nous vous rappelons qu'un travailleur social vous appellera")
        expect(body_string).to include("le 20/12/2021 à 12:00")
        expect(body_string).to include("sur votre numéro de téléphone:")
        expect(body_string).to include("+33607070707")
        expect(body_string).not_to include("20 avenue de ségur 75007 Paris")
        expect(body_string).to include("Ce rendez-vous est obligatoire")
        expect(body_string).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end
  end
end
