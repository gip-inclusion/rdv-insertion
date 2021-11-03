RSpec.describe InvitationMailer, type: :mailer do
  subject do
    described_class.first_invitation(invitation, applicant)
  end

  describe "#first_invitation" do
    let!(:rdv_solidarites_user_id) { 14 }
    let!(:organisation) { create(:organisation, phone_number: "0123456789") }
    let!(:applicant) do
      create(:applicant, organisations: [organisation], rdv_solidarites_user_id: rdv_solidarites_user_id)
    end
    let!(:invitation) { create(:invitation, organisation: organisation, applicant: applicant) }

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("Prenez RDV pour votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour #{applicant.first_name} #{applicant.last_name.upcase},")
    end
  end
end
