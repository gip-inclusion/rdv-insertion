describe Invitations::CreateInvitations, type: :service do
  subject do
    described_class.call(
      applicant: applicant, invitation_format: invitation_format,
      link: invitation_link, token: token
    )
  end

  let!(:invitation_format) { "sms" }
  let!(:rdv_solidarites_user_id) { 14 }
  let!(:department) { create(:department) }
  let!(:applicant) { create(:applicant, department: department, rdv_solidarites_user_id: rdv_solidarites_user_id) }
  let!(:rdv_solidarites_session) do
    { client: "client", uid: "johndoe@example.com", access_token: "token" }
  end
  let!(:invitation) { create(:invitation, applicant: applicant) }

  describe "#call" do
    let!(:token) { "token123" }
    let!(:invitation_link) { "https://www.rdv_solidarites.com/some_params" }
    let!(:rdv_solidarites_user) { instance_double(RdvSolidaritesUser) }

    before do
      allow(Invitation).to receive(:new).and_return(invitation)
      allow(invitation).to receive(:save).and_return(true)
    end

    it "is a success" do
      is_a_success
    end

    it "creates an invitation" do
      expect(Invitation).to receive(:new)
      expect(invitation).to receive(:save)
      subject
    end

    it "returns an invitation array" do
      expect(subject.invitations).to eq([invitation])
    end

    context "invitation creation" do
      it "creates the invitation with the link and token" do
        expect(Invitation).to receive(:new)
          .with(
            applicant: applicant, format: invitation_format,
            token: token, link: invitation_link
          )
        expect(invitation).to receive(:save)
        subject
      end

      context "if invitation_format is sms_and_email" do
        let!(:invitation_format) { "sms_and_email" }
        let!(:invitation) { create(:invitation, applicant: applicant) }
        let!(:email_invitation) { create(:invitation, applicant: applicant) }

        before do
          allow(Invitation).to receive(:new).and_return(email_invitation)
        end

        it "creates two invitations" do
          expect(subject.invitations.count).to eq(2)
        end

        it "creates an sms invitation" do
          expect(subject.invitations).to include(invitation)
        end

        it "creates an email invitation" do
          expect(subject.invitations).to include(email_invitation)
        end
      end
    end
  end
end
