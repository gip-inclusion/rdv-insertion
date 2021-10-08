describe Invitations::SendEmail, type: :service do
  subject do
    described_class.call(
      invitation: invitation
    )
  end

  let!(:email) { "test@test.fr" }
  let!(:applicant) { create(:applicant, email: email) }
  let!(:invitation) { create(:invitation, applicant: applicant) }

  describe "#call" do
    before do
      mail_mock = instance_double("deliver_now: true")
      allow(InvitationMailer).to receive(:first_invitation)
        .and_return(mail_mock)
      allow(mail_mock).to receive(:deliver_now)
    end

    it("is a success") { is_a_success }

    it "calls the invitation mail" do
      expect(InvitationMailer).to receive(:first_invitation)
        .with(invitation, applicant)
      subject
    end

    context "when the mail is blank" do
      let!(:email) { "" }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["L'email doit être renseigné"])
      end
    end

    context "when the mail is invalid" do
      let!(:email) { "abcd" }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["L'email renseigné ne semble pas être une adresse valable"])
      end
    end
  end
end
