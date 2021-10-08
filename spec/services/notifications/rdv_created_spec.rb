describe Notifications::RdvCreated, type: :service do
  subject do
    described_class.call(
      applicant: applicant, rdv_solidarites_rdv: rdv_solidarites_rdv
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
  let!(:rdv_solidarites_rdv_id) { 23 }
  let!(:rdv_solidarites_rdv) do
    OpenStruct.new(
      id: rdv_solidarites_rdv_id, lieu: lieu, motif: motif,
      formatted_start_date: starts_at.to_datetime.strftime("%d/%m/%Y"),
      formatted_start_time: starts_at.to_datetime.strftime('%H:%M')
    )
  end
  let!(:department) do
    create(:department, phone_number: "0147200001", name: "Yonne", number: "89")
  end
  let!(:notification) { create(:notification, applicant: applicant) }
  let!(:lieu) { OpenStruct.new(name: "DINUM", address: "20 avenue de Ségur 75011 PARIS") }
  let!(:motif) { OpenStruct.new(location_type: "public_office") }
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
        .with(event: "rdv_created", applicant: applicant, rdv_solidarites_rdv_id: rdv_solidarites_rdv_id)
      subject
    end

    context "when the rdv is presential" do
      before do
        rdv_solidarites_rdv[:presential?] = true
      end

      let!(:content) do
        "Monsieur John DOE,\nVous êtes allocataire du RSA. Vous bénéficiez d’un accompagnement " \
          "dans le cadre de vos démarches d’insertion. Vous êtes attendu(e) le 08/09/2021 à " \
          "12:00 ici: DINUM - 20 avenue de Ségur 75011 PARIS. Ce rendez-vous est obligatoire. "\
          "En cas d’empêchement, merci d’appeler rapidement le 0147200001. " \
          "Le département 89 (Yonne)."
      end

      it "sends the sms with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number: phone_number, content: content)
        subject
      end
    end

    context "when the rdv is remote" do
      before do
        rdv_solidarites_rdv[:presential?] = false
      end

      let!(:content) do
        "Monsieur John DOE,\nVous êtes allocataire du RSA. Vous bénéficiez d’un accompagnement" \
          " dans le cadre de vos démarches d’insertion. Un travailleur social vous appellera le 08/09/2021" \
          " à partir de 12:00 sur ce numéro. Ce rendez-vous est obligatoire. En cas d’empêchement, merci d’appeler "\
          "rapidement le 0147200001. Le département 89 (Yonne)."
      end

      it "sends the sms with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number: phone_number, content: content)
        subject
      end
    end
  end
end
