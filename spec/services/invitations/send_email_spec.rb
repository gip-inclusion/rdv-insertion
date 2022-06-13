describe Invitations::SendEmail, type: :service do
  subject do
    described_class.call(
      invitation: invitation
    )
  end

  let!(:applicant) { create(:applicant) }

  describe "#call" do
    context "for rsa orientation" do
      let!(:invitation) do
        create(
          :invitation,
          applicant: applicant, format: "email",
          rdv_context: build(:rdv_context, motif_category: "rsa_orientation")
        )
      end

      before do
        mail_mock = instance_double("deliver_now: true")
        allow(InvitationMailer).to receive(:invitation_for_rsa_orientation)
          .and_return(mail_mock)
        allow(mail_mock).to receive(:deliver_now)
      end

      it("is a success") { is_a_success }

      it "calls the invitation mail" do
        expect(InvitationMailer).to receive(:invitation_for_rsa_orientation)
          .with(invitation, applicant)
        subject
      end

      context "when the format is not an email" do
        let!(:invitation) { create(:invitation, applicant: applicant, format: "sms") }

        it("is a failure") { is_a_failure }

        it "returns the error" do
          expect(subject.errors).to eq(["Envoi d'un email alors que le format est sms"])
        end
      end

      context "when the mail is blank" do
        let!(:applicant) { create(:applicant, email: nil) }

        it("is a failure") { is_a_failure }

        it "returns the error" do
          expect(subject.errors).to eq(["L'email doit être renseigné"])
        end
      end

      context "when the mail is invalid" do
        let!(:applicant) { create(:applicant, :skip_validate, email: "abcd") }

        it("is a failure") { is_a_failure }

        it "returns the error" do
          expect(subject.errors).to eq(["L'email renseigné ne semble pas être une adresse valable"])
        end
      end
    end
  end

  context "for rsa accompagnement" do
    let!(:invitation) do
      create(
        :invitation,
        applicant: applicant, format: "email",
        rdv_context: build(:rdv_context, motif_category: "rsa_accompagnement")
      )
    end

    before do
      mail_mock = instance_double("deliver_now: true")
      allow(InvitationMailer).to receive(:invitation_for_rsa_accompagnement)
        .and_return(mail_mock)
      allow(mail_mock).to receive(:deliver_now)
    end

    it("is a success") { is_a_success }

    it "calls the invitation mail" do
      expect(InvitationMailer).to receive(:invitation_for_rsa_accompagnement)
        .with(invitation, applicant)
      subject
    end
  end

  context "for rsa orientation on phone platform" do
    let!(:invitation) do
      create(
        :invitation,
        applicant: applicant, format: "email",
        rdv_context: build(:rdv_context, motif_category: "rsa_orientation_on_phone_platform")
      )
    end

    before do
      mail_mock = instance_double("deliver_now: true")
      allow(InvitationMailer).to receive(:invitation_for_rsa_orientation_on_phone_platform)
        .and_return(mail_mock)
      allow(mail_mock).to receive(:deliver_now)
    end

    it("is a success") { is_a_success }

    it "calls the invitation mail" do
      expect(InvitationMailer).to receive(:invitation_for_rsa_orientation_on_phone_platform)
        .with(invitation, applicant)
      subject
    end
  end
end
