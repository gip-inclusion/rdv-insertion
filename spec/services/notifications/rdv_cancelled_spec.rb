describe Notifications::RdvCancelled, type: :service do
  subject do
    described_class.call(
      applicant: applicant, lieu: lieu, starts_at: starts_at, motif: motif
    )
  end

  let!(:phone_number) { "+33782605941" }
  let!(:applicant) do
    create(
      :applicant,
      phone_number_formatted: phone_number,
      first_name: "john",
      last_name: "doe",
      title: "monsieur",
      department: department
    )
  end
  let!(:department) do
    create(:department, phone_number: "0147200001", name: "Yonne", number: "89")
  end
  let!(:notification) { create(:notification, applicant: applicant) }
  let!(:lieu) { { name: "DINUM", address: "20 avenue de Ségur 75011 PARIS" } }
  let!(:motif) { { location_type: "public_office" } }
  let!(:starts_at) { "2021-09-08 12:00:00 UTC" }

  describe "#call" do
    before do
      allow(Notification).to receive(:new).and_return(notification)
      allow(notification).to receive(:save).and_return(true)
      allow(SendTransactionalSms).to receive(:call).and_return(OpenStruct.new(success?: true))
      allow(notification).to receive(:update).and_return(true)
    end

    it "saves the notification with the right event" do
      expect(Notification).to receive(:new)
        .with(event: "rdv_cancelled", applicant: applicant)
      subject
    end

    context "when the rdv is presential" do
      let!(:content) do
        "Monsieur John DOE,\nVotre RDV d'orientation RSA a été annulé. " \
          "Veuillez contacter le 0147200001 pour plus d'informations."
      end

      it "sends the sms with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number: phone_number, content: content)
        subject
      end
    end
  end
end
