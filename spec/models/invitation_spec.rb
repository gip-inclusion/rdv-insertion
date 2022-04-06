describe Invitation do
  describe "#valid?" do
    let!(:department) { create(:department) }
    let!(:organisation) { create(:organisation, department: department) }
    let!(:applicant) { create(:applicant) }
    let!(:rdv_context) { build(:rdv_context, context: "rsa_orientation") }
    let!(:invitation) do
      build(
        :invitation,
        organisations: [organisation], department: department, rdv_context: rdv_context,
        help_phone_number: "0101010101", applicant: applicant, token: "token", link: "https://www.rdv-solidarites.fr"
      )
    end

    it { expect(invitation).to be_valid }

    context "when no token" do
      before { invitation.token = nil }

      it { expect(invitation).not_to be_valid }
    end

    context "when no link" do
      before { invitation.link = nil }

      it { expect(invitation).not_to be_valid }
    end

    context "when no help_phone_number" do
      before { invitation.help_phone_number = nil }

      it { expect(invitation).not_to be_valid }
    end

    context "when no organisations" do
      before { invitation.organisations = [] }

      it { expect(invitation).not_to be_valid }
    end

    context "when the organisation does not belong to the same department" do
      let!(:other_department) { create(:department) }
      let!(:organisation) { create(:organisation, department: other_department) }

      it { expect(invitation).not_to be_valid }
    end
  end
end
