describe Notifications::RdvCancelled, type: :service do
  subject do
    described_class.call(
      applicant: applicant, rdv_solidarites_rdv: rdv_solidarites_rdv,
      organisation: organisation
    )
  end

  let!(:phone_number_formatted) { "+33782605941" }
  let!(:phone_number) { "0782605941" }
  let!(:applicant) do
    create(
      :applicant,
      phone_number: phone_number,
      first_name: "john",
      last_name: "doe",
      title: "monsieur",
      organisations: [organisation]
    )
  end
  let!(:rdv_solidarites_rdv_id) { 23 }
  let!(:rdv_solidarites_rdv) do
    OpenStruct.new(id: rdv_solidarites_rdv_id)
  end
  let!(:department) { create(:department, name: "Yonne", number: "89") }

  let!(:organisation) do
    create(:organisation, phone_number: "0147200001", department: department)
  end
  let!(:notification) { create(:notification, applicant: applicant) }

  describe "#call" do
    before do
      allow(Notification).to receive(:new).and_return(notification)
      allow(notification).to receive(:save).and_return(true)
      allow(SendTransactionalSms).to receive(:call).and_return(OpenStruct.new(success?: true))
      allow(notification).to receive(:update).and_return(true)
    end

    it "saves the notification with the right event" do
      expect(Notification).to receive(:new)
        .with(event: "rdv_cancelled", applicant: applicant, rdv_solidarites_rdv_id: rdv_solidarites_rdv_id)
      subject
    end

    context "when the rdv is presential" do
      let!(:content) do
        "Monsieur John DOE,\nVotre RDV d'orientation RSA a été annulé. " \
          "Veuillez contacter le 0147200001 pour plus d'informations."
      end

      it "sends the sms with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number_formatted: phone_number_formatted,
                sender_name: "Dept#{department.number}",
                content: content)
        subject
      end
    end
  end
end
