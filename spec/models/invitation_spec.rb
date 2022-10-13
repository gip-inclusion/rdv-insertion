describe Invitation do
  describe "#valid?" do
    let!(:department) { create(:department) }
    let!(:organisation) { create(:organisation, department: department) }
    let!(:applicant) { create(:applicant) }
    let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_orientation") }
    let!(:invitation) do
      build(
        :invitation,
        organisations: [organisation], department: department, rdv_context: rdv_context,
        help_phone_number: "0101010101", applicant: applicant, rdv_solidarites_token: "rdv_solidarites_token",
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

    context "when it is a postal invitation that expires in less than 5 days" do
      before do
        travel_to(Time.zone.parse("2022-05-04"))
        invitation.format = "postal"
        invitation.valid_until = Time.zone.parse("2022-05-08")
      end

      it { expect(invitation).not_to be_valid }
    end
  end
end
