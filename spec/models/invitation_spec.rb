describe Invitation do
  describe "#valid?" do
    let!(:department) { create(:department) }
    let!(:organisation) { create(:organisation, department: department) }
    let!(:user) { create(:user) }
    let!(:rdv_context) { build(:rdv_context) }
    let!(:invitation) do
      build(
        :invitation,
        organisations: [organisation], department: department, rdv_context: rdv_context,
        help_phone_number: "0101010101", user: user, rdv_solidarites_token: "rdv_solidarites_token",
        link: "https://www.rdv-solidarites.fr"
      )
    end

    it { expect(invitation).to be_valid }

    context "when no rdv_solidarites_token" do
      before { invitation.rdv_solidarites_token = nil }

      it { expect(invitation).not_to be_valid }
    end

    context "when no link" do
      before { invitation.link = nil }

      it { expect(invitation).not_to be_valid }
    end

    context "when no help_phone_number" do
      before do
        invitation.help_phone_number = nil
        organisation.update!(phone_number: nil)
      end

      it "has an error message" do
        expect(invitation).not_to be_valid
        expect(invitation.errors.messages[:base]).to include(
          "Le téléphone de contact de l'organisation #{organisation.name} doit être indiqué."
        )
      end
    end

    context "when no organisations" do
      before { invitation.organisations = [] }

      it { expect(invitation).not_to be_valid }
    end
  end
end
