describe Invitations::GenerateLetter, type: :service do
  subject do
    described_class.call(
      invitation: invitation
    )
  end

  let!(:applicant) { create(:applicant) }
  let!(:department) { create(:department) }
  let!(:invitation) do
    create(
      :invitation, content: nil, applicant: applicant, organisations: [organisation],
                   department: department, format: "postal"
    )
  end
  let!(:organisation) { create(:organisation, responsible: responsible, department: department) }
  let!(:responsible) { create(:responsible, first_name: "Gael", last_name: "Monfils") }

  describe "#call" do
    it("is a success") { is_a_success }

    it "generates the pdf string" do
      subject
      expect(invitation.content).not_to eq(nil)
      expect(invitation.content).to match(/saisissez le code d’invitation ci-dessous, puis suivez les instructions/)
      expect(invitation.content).to match(/Gael Monfils/)
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
