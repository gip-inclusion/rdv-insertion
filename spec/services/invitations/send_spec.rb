describe Invitations::Send, type: :service do
  subject do
    described_class.call(
      invitation: invitation,
      rdv_solidarites_user: rdv_solidarites_user
    )
  end

  let!(:applicant) { create(:applicant) }
  let!(:phone_number_formatted) { '+33782692828' }
  let!(:invitation) { create(:invitation, applicant: applicant) }
  let!(:rdv_solidarites_user) { RdvSolidaritesUser.new(phone_number_formatted: phone_number_formatted) }

  describe "#call" do
    context "when the invitation format is sms" do
      let!(:invitation) { create(:invitation, format: "sms", applicant: applicant) }

      before do
        allow(Invitations::SendSms).to receive(:call)
      end

      it("is a success") { is_a_success }

      it "calls the send sms invitation service" do
        expect(Invitations::SendSms).to receive(:call)
          .with(invitation: invitation, phone_number: phone_number_formatted)
        subject
      end
    end

    context "when the format is link only" do
      let!(:invitation) { create(:invitation, format: "link_only", applicant: applicant) }

      it("is a success") { is_a_success }

      it "does not call the sms invitation service" do
        expect(Invitations::SendSms).not_to receive(:call)
        subject
      end
    end
  end
end
