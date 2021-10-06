RSpec.describe InvitationMailer, type: :mailer do
  subject do
    described_class.first_invitation(invitation, applicant)
  end

  describe "#first_invitation" do
    let!(:rdv_solidarites_user_id) { 14 }
    let!(:department) { create(:department, phone_number: "0123456789") }
    let!(:applicant) { create(:applicant, department: department, rdv_solidarites_user_id: rdv_solidarites_user_id) }
    let!(:invitation) { create(:invitation, applicant: applicant) }

    it "renders the headers" do
      expect(subject.to).to eq([applicant.email])
    end

    it "renders the subject" do
      expect(subject.subject).to eq("Prenez RDV pour votre RSA")
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Bonjour #{applicant.first_name} #{applicant.last_name.upcase},")
    end

    it "sends the invitation link" do
      expect(subject.body).to match(invitation.link.to_s)
    end
  end
end
