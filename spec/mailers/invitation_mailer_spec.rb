RSpec.describe InvitationMailer, type: :mailer do
  subject do
    described_class.first_invitation(invitation, applicant)
  end

  describe "#first_invitation" do
    let!(:department) { create(:department, name: "Drôme", pronoun: "la") }
    let!(:help_phone_number) { "0139393939" }
    let!(:organisation) { create(:organisation, department: department) }
    let!(:applicant) do
      create(:applicant, first_name: "Jean", last_name: "Valjean")
    end
    let!(:token) { "some_token" }

    let!(:invitation) do
      create(:invitation, applicant: applicant, token: token, department: department, format: "email")
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
    end
  end
end
