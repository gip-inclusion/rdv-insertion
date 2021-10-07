describe Invitations::RetrieveOrCreateInvitation, type: :service do
  subject do
    described_class.call(
      applicant: applicant, rdv_solidarites_session: rdv_solidarites_session,
      invitation_format: invitation_format
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
    before do
      allow(Invitations::CreateInvitation).to receive(:call)
        .and_return(OpenStruct.new(success?: true, invitation: invitation))
      allow(invitation).to receive(:send_to_applicant)
        .and_return(OpenStruct.new(success?: true))
    end

    it "is a success" do
      is_a_success
    end

    it "returns an invitation" do
      expect(subject.invitation).to eq(invitation)
    end

    context "invitation creation" do
      context "when the user has no invitation with the requested format" do
        let!(:invitation) { create(:invitation, applicant: applicant, format: "email") }

        it "tries to create an invitation" do
          expect(Invitations::CreateInvitation).to receive(:call)
            .with(
              applicant: applicant,
              invitation_format: invitation_format,
              rdv_solidarites_session: rdv_solidarites_session
            )
          subject
        end

        context "when it fails" do
          before do
            allow(Invitations::CreateInvitation).to receive(:call)
              .and_return(OpenStruct.new(success?: false, errors: ["something happened"]))
          end

          it "is a failure" do
            is_a_failure
          end

          it "stores the error" do
            expect(subject.errors).to eq(["something happened"])
          end

          it "does not create an invitation" do
            expect { subject }.to change(Invitation, :count).by(0)
          end
        end
      end

      context "when the user has already an invitation with the requested format" do
        it "does not try to create an invitation" do
          expect(Invitations::CreateInvitation).not_to receive(:call)
          subject
        end
      end
    end
  end
end
