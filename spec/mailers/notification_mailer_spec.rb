RSpec.describe NotificationMailer, type: :mailer do
  let!(:applicant) { create(:applicant, email: "someone@gmail.com", phone_number: "0607070707") }
  let!(:rdv) { create(:rdv, lieu: lieu, starts_at: Time.zone.parse("20/12/2021 12:00")) }
  let!(:lieu) { create(:lieu, name: "DINUM", address: "20 avenue de ségur 75007 Paris", phone_number: "0101010101") }
  let!(:signature_lines) { ["Signé par la DINUM"] }
  let!(:motif_category) { "rsa_orientation" }

  describe "#presential_rdv_created" do
    let!(:mail) do
      described_class.with(
        applicant: applicant, rdv: rdv, signature_lines: signature_lines, motif_category: motif_category
      ).presential_rdv_created
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
          "[Important - RSA] Vous êtes convoqué(e) à un rendez-vous d'orientation"
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un rendez-vous d&#39;orientation"
        )
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("DINUM")
        expect(mail.body.encoded).to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnement" do
      let!(:motif_category) { "rsa_accompagnement" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué(e) à un rendez-vous d'accompagnement"
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un rendez-vous d&#39;accompagnement"
        )
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("DINUM")
        expect(mail.body.encoded).to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa cer signature" do
      let!(:motif_category) { "rsa_cer_signature" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué(e) à un rendez-vous pour construire" \
          " et signer votre Contrat d'Engagement Réciproque"
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un rendez-vous pour construire" \
          " et signer votre Contrat d&#39;Engagement Réciproque"
        )
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("DINUM")
        expect(mail.body.encoded).to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa follow up" do
      let!(:motif_category) { "rsa_follow_up" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué(e) à un rendez-vous de suivi avec votre référent de parcours" \
          ""
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un rendez-vous de suivi" \
          " avec votre référent de parcours"
        )
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("DINUM")
        expect(mail.body.encoded).to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).not_to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end
  end

  describe "#presential_rdv_updated" do
    let!(:mail) do
      described_class.with(
        applicant: applicant, rdv: rdv, signature_lines: signature_lines, motif_category: motif_category
      ).presential_rdv_updated
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
        expect(mail.body.encoded).to include(
          "Votre rendez-vous d&#39;orientation dans le cadre de votre RSA a été modifié"
        )
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("DINUM")
        expect(mail.body.encoded).to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnement" do
      let!(:motif_category) { "rsa_accompagnement" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'accompagnement a été modifié."
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Votre rendez-vous d&#39;accompagnement dans le cadre de votre RSA a été modifié"
        )
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("DINUM")
        expect(mail.body.encoded).to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa cer signature" do
      let!(:motif_category) { "rsa_cer_signature" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous pour construire" \
          " et signer votre Contrat d'Engagement Réciproque " \
          "a été modifié."
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Votre rendez-vous pour construire et signer votre Contrat d&#39;Engagement"\
          " Réciproque dans le cadre de votre RSA a été modifié."
        )
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("DINUM")
        expect(mail.body.encoded).to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa follow up" do
      let!(:motif_category) { "rsa_follow_up" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous de suivi avec votre référent de parcours" \
          " a été modifié."
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Votre rendez-vous de suivi" \
          " avec votre référent de parcours dans le cadre de votre RSA a été modifié"
        )
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("DINUM")
        expect(mail.body.encoded).to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).not_to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end
  end

  describe "#by_phone_rdv_created" do
    let!(:mail) do
      described_class.with(
        applicant: applicant, rdv: rdv, signature_lines: signature_lines, motif_category: motif_category
      ).by_phone_rdv_created
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
          "[Important - RSA] Vous êtes convoqué(e) à un rendez-vous d'orientation téléphonique"
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un rendez-vous d&#39;orientation" \
          " téléphonique"
        )
        expect(mail.body.encoded).to include("Un travailleur social vous appellera")
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("sur votre numéro de téléphone:")
        expect(mail.body.encoded).to include("+33607070707")
        expect(mail.body.encoded).not_to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnement" do
      let!(:motif_category) { "rsa_accompagnement" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué(e) à un rendez-vous d'accompagnement téléphonique"
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) " \
          "à un rendez-vous d&#39;accompagnement téléphonique"
        )
        expect(mail.body.encoded).to include("Un travailleur social vous appellera")
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("sur votre numéro de téléphone:")
        expect(mail.body.encoded).to include("+33607070707")
        expect(mail.body.encoded).not_to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa cer signature" do
      let!(:motif_category) { "rsa_cer_signature" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué(e) à un rendez-vous téléphonique pour construire" \
          " et signer votre Contrat d'Engagement Réciproque"
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un rendez-vous téléphonique"\
          " pour construire et signer votre Contrat d&#39;Engagement Réciproque"
        )
        expect(mail.body.encoded).to include("Un travailleur social vous appellera")
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("sur votre numéro de téléphone:")
        expect(mail.body.encoded).to include("+33607070707")
        expect(mail.body.encoded).not_to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa follow up" do
      let!(:motif_category) { "rsa_follow_up" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Vous êtes convoqué(e) à un rendez-vous de suivi téléphonique avec "\
          "votre référent de parcours"
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Vous êtes bénéficiaire du RSA et à ce titre vous avez été convoqué(e) à un rendez-vous de suivi " \
          "téléphonique avec votre référent de parcours"\
        )
        expect(mail.body.encoded).to include("Un travailleur social vous appellera")
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("sur votre numéro de téléphone:")
        expect(mail.body.encoded).to include("+33607070707")
        expect(mail.body.encoded).not_to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).not_to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).not_to include(
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

  describe "#by_phone_rdv_updated" do
    let!(:mail) do
      described_class.with(
        applicant: applicant, rdv: rdv, signature_lines: signature_lines, motif_category: motif_category
      ).by_phone_rdv_updated
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
        expect(mail.body.encoded).to include(
          "Votre rendez-vous d&#39;orientation téléphonique dans le cadre de votre RSA a été modifié."
        )
        expect(mail.body.encoded).to include("Un travailleur social vous appellera")
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("sur votre numéro de téléphone:")
        expect(mail.body.encoded).to include("+33607070707")
        expect(mail.body.encoded).not_to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa accompagnement" do
      let!(:motif_category) { "rsa_accompagnement" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'accompagnement téléphonique a été modifié."
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Votre rendez-vous d&#39;accompagnement téléphonique dans le cadre de votre RSA a été modifié."
        )
        expect(mail.body.encoded).to include("Un travailleur social vous appellera")
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("sur votre numéro de téléphone:")
        expect(mail.body.encoded).to include("+33607070707")
        expect(mail.body.encoded).not_to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa cer signature" do
      let!(:motif_category) { "rsa_cer_signature" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous téléphonique pour construire" \
          " et signer votre Contrat d'Engagement Réciproque a été modifié."
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Votre rendez-vous téléphonique pour construire et signer votre Contrat d&#39;Engagement Réciproque" \
          " dans le cadre de votre RSA a été modifié"
        )
        expect(mail.body.encoded).to include("Un travailleur social vous appellera")
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("sur votre numéro de téléphone:")
        expect(mail.body.encoded).to include("+33607070707")
        expect(mail.body.encoded).not_to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).not_to include(
          "En cas d'absence, le versement de votre RSA pourra être suspendu ou réduit."
        )
      end
    end

    context "for rsa follow up" do
      let!(:motif_category) { "rsa_follow_up" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous de suivi téléphonique avec "\
          "votre référent de parcours a été modifié."
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Votre rendez-vous de suivi " \
          "téléphonique avec votre référent de parcours dans le cadre de votre RSA a été modifié"\
        )
        expect(mail.body.encoded).to include("Un travailleur social vous appellera")
        expect(mail.body.encoded).to include("le 20/12/2021 à 12:00")
        expect(mail.body.encoded).to include("sur votre numéro de téléphone:")
        expect(mail.body.encoded).to include("+33607070707")
        expect(mail.body.encoded).not_to include("20 avenue de ségur 75007 Paris")
        expect(mail.body.encoded).not_to include("Ce rendez-vous est obligatoire")
        expect(mail.body.encoded).not_to include(
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

  describe "#rdv_cancelled" do
    let!(:mail) do
      described_class.with(
        applicant: applicant, rdv: rdv, signature_lines: signature_lines, motif_category: motif_category
      ).rdv_cancelled
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
        expect(mail.body.encoded).to include(
          "Votre rendez-vous d&#39;orientation dans le cadre de votre RSA a été annulé."
        )
        expect(mail.body.encoded).to include("our plus d'informations, veuillez appeler le 0101010101")
      end
    end

    context "for rsa accompagnement" do
      let!(:motif_category) { "rsa_accompagnement" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous d'accompagnement a été annulé."
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Votre rendez-vous d&#39;accompagnement dans le cadre de votre RSA a été annulé."
        )
        expect(mail.body.encoded).to include("our plus d'informations, veuillez appeler le 0101010101")
      end
    end

    context "for rsa cer signature" do
      let!(:motif_category) { "rsa_cer_signature" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous pour construire" \
          " et signer votre Contrat d'Engagement Réciproque a été annulé."
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Votre rendez-vous pour construire et signer votre Contrat d&#39;Engagement Réciproque" \
          " dans le cadre de votre RSA a été annulé"
        )
        expect(mail.body.encoded).to include("our plus d'informations, veuillez appeler le 0101010101")
      end
    end

    context "for rsa follow up" do
      let!(:motif_category) { "rsa_follow_up" }

      it "renders the subject" do
        expect(mail.subject).to eq(
          "[Important - RSA] Votre rendez-vous de suivi avec "\
          "votre référent de parcours a été annulé."
        )
      end

      it "renders the body" do
        expect(mail.body.encoded).to include(
          "Votre rendez-vous de suivi " \
          "avec votre référent de parcours dans le cadre de votre RSA a été annulé"\
        )
        expect(mail.body.encoded).to include("our plus d'informations, veuillez appeler le 0101010101")
      end
    end
  end
end
