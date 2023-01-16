describe Messengers::SendSms, type: :service do
  subject do
    described_class.call(
      sendable: invitation,
      content: content
    )
  end

  describe "#call" do
    let!(:invitation) do
      create(:invitation, format: "sms", applicant: applicant, organisations: [organisation], department: department)
    end
    let!(:content) { "some message to send" }
    let!(:phone_number) { "0790909090" }
    let!(:phone_number_formatted) { "+33790909090" }

    let!(:applicant) { create(:applicant, phone_number: phone_number, department: department) }
    let!(:organisation) { create(:organisation, department: department) }
    let!(:department) { create(:department, number: "26") }

    before do
      allow(Rails).to receive_message_chain(:env, :production?).and_return(true)
      allow(SendTransactionalSms).to receive(:call)
    end

    it("is a success") { is_a_success }

    it "calls the transactional sms service" do
      expect(SendTransactionalSms).to receive(:call)
        .with(
          content: content, phone_number_formatted: phone_number_formatted,
          sender_name: "Dept26"
        )
      subject
    end

    context "when a sms sender name is specified in the configuration" do
      let!(:messages_configuration) do
        create(:messages_configuration, sms_sender_name: "Rdvi", organisations: [organisation])
      end

      it "calls the transactional sms servic with the specified sms sender name" do
        expect(SendTransactionalSms).to receive(:call)
          .with(
            content: content, phone_number_formatted: phone_number_formatted,
            sender_name: "Rdvi"
          )
        subject
      end
    end

    context "when the sendable format is not sms" do
      before { invitation.format = "email" }

      it("is a failure") { is_a_failure }

      it "returns an error" do
        expect(subject.errors).to eq(["Envoi de SMS alors que le format est email"])
      end
    end

    context "when the phone number is blank" do
      let!(:phone_number) { "" }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Le téléphone doit être renseigné"])
      end
    end

    context "when the phone number is not a mobile" do
      let!(:phone_number) { "0123456789" }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Le numéro de téléphone doit être un mobile"])
      end
    end

    context "when the phone number is not a metropolitan mobile" do
      let!(:phone_number) { "0692926878" }

      it("is a success") { is_a_success }
    end
  end
end
