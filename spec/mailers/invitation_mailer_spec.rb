RSpec.describe InvitationMailer, type: :mailer do
  let!(:department) { create(:department, name: "Drôme", pronoun: "la") }
  let!(:help_phone_number) { "0139393939" }
  let!(:configuration) { create(:configuration) }
  let!(:organisation) { create(:organisation, department: department, configurations: [configuration]) }
  let!(:applicant) do
    create(:applicant, first_name: "Jean", last_name: "Valjean")
  end
  let!(:invitation) do
    create(
      :invitation,
      applicant: applicant, token: token, department: department, format: "email", help_phone_number: help_phone_number,
      number_of_days_to_accept_invitation: 5, organisations: [organisation]
    )
  end
  let!(:token) { "some_token" }

  describe "#invitation_for_rsa_orientation" do
    subject do
      described_class.invitation_for_rsa_orientation(invitation, applicant)
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("RDV d'orientation dans le cadre de votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "Vous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous d'orientation"
      )
      expect(subject.body.encoded).to match("/invitations/redirect")
      expect(subject.body.encoded).to match("token=some_token")
      expect(subject.body.encoded).to match("dans les 5 jours")
    end

    context "when the signature is configured" do
      let!(:configuration) { create(:configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match("Fabienne Bouchet")
      end
    end

    context "when the help address is configured" do
      let!(:configuration) { create(:configuration, help_address: "10, rue du Conseil départemental 75001 Paris") }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match("10, rue du Conseil départemental 75001 Paris")
      end
    end
  end

  describe "#invitation_for_rsa_accompagnement" do
    subject do
      described_class.invitation_for_rsa_accompagnement(invitation, applicant)
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("RDV d'accompagnement dans le cadre de votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour Jean VALJEAN")
      expect(subject.body.encoded).to match("Le département de la Drôme.")
      expect(subject.body.encoded).to match("01 39 39 39 39")
      expect(subject.body.encoded).to match(
        "Vous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous d'accompagnement."
      )
      expect(subject.body.encoded).to match("/invitations/redirect")
      expect(subject.body.encoded).to match("token=some_token")
      expect(subject.body.encoded).to match("dans les 5 jours")
    end

    context "when the signature is configured" do
      let!(:configuration) { create(:configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end

    context "when the help address is configured" do
      let!(:configuration) { create(:configuration, help_address: "10, rue du Conseil départemental 75001 Paris") }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match("10, rue du Conseil départemental 75001 Paris")
      end
    end
  end

  describe "#invitation_for_rsa_orientation_on_phone_platform" do
    subject do
      described_class.invitation_for_rsa_orientation_on_phone_platform(invitation, applicant)
    end

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("RDV d'orientation téléphonique dans le cadre de votre RSA")
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
      let!(:configuration) { create(:configuration, signature_lines: ["Fabienne Bouchet"]) }

      it "renders the mail with the right signature" do
        expect(subject.body.encoded).to match(/Fabienne Bouchet/)
      end
    end
  end
end
