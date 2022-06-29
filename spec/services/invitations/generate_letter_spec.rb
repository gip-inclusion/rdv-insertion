describe Invitations::GenerateLetter, type: :service do
  subject do
    described_class.call(
      invitation: invitation
    )
  end

  let!(:applicant) { create(:applicant) }
  let!(:department) { create(:department) }
  let!(:rdv_context) { create(:rdv_context) }
  let!(:invitation) do
    create(
      :invitation, content: nil, applicant: applicant, organisations: [organisation],
                   department: department, format: "postal", rdv_context: rdv_context
    )
  end
  let!(:invitation_parameters) { create(:invitation_parameters) }
  let!(:organisation) do
    create(:organisation, invitation_parameters: invitation_parameters,
                          department: department)
  end

  describe "#call" do
    it("is a success") { is_a_success }

    it "generates the pdf string with default configuration" do
      subject
      expect(invitation.content).not_to eq(nil)
      expect(invitation.content).to match(/Pour choisir un créneau à votre convenance, saisissez le code d’invitation/)
      expect(invitation.content).to match(/#{department.name}/)
      expect(invitation.content).not_to match(/col-1/)
    end

    context "when the signature is configured" do
      let!(:invitation_parameters) { create(:invitation_parameters, signature_lines: ["Fabienne Bouchet"]) }

      it "generates the pdf string with the right signature" do
        subject
        expect(invitation.content).to match(/Fabienne Bouchet/)
      end
    end

    context "when the europe logos are configured to be displayed" do
      let!(:invitation_parameters) { create(:invitation_parameters, display_europe_logos: true) }

      it "generates the pdf string with the europe logos" do
        subject
        expect(invitation.content).to match(/col-1/)
      end
    end

    context "when the context is orientation" do
      context "when the help address is configured" do
        let!(:rdv_context) { create(:rdv_context, motif_category: "rsa_orientation") }
        let!(:invitation_parameters) do
          create(:invitation_parameters, help_address: "10, rue du Conseil départemental 75001 Paris")
        end

        it "renders the mail with the help address" do
          subject
          expect(invitation.content).to match("10, rue du Conseil départemental 75001 Paris")
        end
      end
    end

    context "when the context is accompagnement" do
      context "when the help address is configured" do
        let!(:rdv_context) { create(:rdv_context, motif_category: "rsa_accompagnement") }
        let!(:invitation_parameters) do
          create(:invitation_parameters, help_address: "10, rue du Conseil départemental 75001 Paris")
        end

        it "renders the mail with the help address" do
          subject
          expect(invitation.content).to match("10, rue du Conseil départemental 75001 Paris")
        end
      end
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
