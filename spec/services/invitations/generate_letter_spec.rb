describe Invitations::GenerateLetter, type: :service do
  subject do
    described_class.call(
      invitation: invitation
    )
  end

  let!(:applicant) { create(:applicant) }
  let!(:invitation) { create(:invitation, content: nil, applicant: applicant, format: "postal") }

  describe "#call" do
    it("is a success") { is_a_success }

    it "generates the pdf string" do
      subject
      expect(invitation.content).not_to eq(nil)
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
        expect(subject.errors).to eq(["L'adresse n'est pas complète ou elle n'est pas enregistrée correctement." \
                                      "<br/><br/>Format attendu&nbsp;:<br/>10 rue de l'envoi 12345 - La Ville"])
      end
    end
  end
end
