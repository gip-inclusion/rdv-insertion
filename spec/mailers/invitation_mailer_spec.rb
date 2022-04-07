RSpec.describe InvitationMailer, type: :mailer do
  let!(:department) { create(:department, name: "Drôme", pronoun: "la") }
  let!(:help_phone_number) { "0139393939" }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:applicant) do
    create(:applicant, first_name: "Jean", last_name: "Valjean")
  end
  let!(:invitation) do
    create(
      :invitation,
      applicant: applicant, token: token, department: department, format: "email", help_phone_number: help_phone_number
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
      expect(subject.subject).to eq("Prenez RDV pour votre RSA")
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
      expect(subject.subject).to eq("Prenez RDV pour votre RSA")
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
      expect(subject.subject).to eq("Prenez un RDV téléphonique pour votre RSA")
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
    end
  end
end
