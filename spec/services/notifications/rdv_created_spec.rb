describe Notifications::RdvCreated, type: :service do
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
        .with(event: "rdv_created", applicant: applicant)
      subject
    end

    context "when the rdv is presential" do
      let!(:content) do
        "Monsieur John DOE,\nVous êtes allocataire du RSA. Vous bénéficiez d’un accompagnement obligatoire " \
          "dans le cadre de vos démarches d’insertion. Vous êtes attendu(e) le 08/09/2021 à " \
          "12:00 ici: DINUM - 20 avenue de Ségur 75011 PARIS. En cas d’empêchement, merci "\
          "d’appeler rapidement le 0147200001. En cas d’absence, vous risquez une " \
          "suspension de votre allocation RSA. Le département 89 (Yonne)."
      end

      it "sends the sms with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number: phone_number, content: content)
        subject
      end
    end

    context "when the rdv is remote" do
      let!(:motif) { { location_type: "phone" } }
      let!(:content) do
        "Monsieur John DOE,\nVous êtes allocataire du RSA. Vous bénéficiez d’un accompagnement obligatoire" \
          " dans le cadre de vos démarches d’insertion. Un travailleur social vous appellera le 08/09/2021" \
          " à partir de 12:00 sur ce numéro. En cas d’empêchement, merci d’appeler rapidement le " \
          "0147200001. En cas d’absence, vous risquez une uspension de votre allocation RSA." \
          " Le département 89 (Yonne)."
      end

      it "sends the sms with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number: phone_number, content: content)
        subject
      end
    end
  end
end
