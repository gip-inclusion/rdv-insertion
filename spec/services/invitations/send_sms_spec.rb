describe Invitations::SendSms, type: :service do
  subject do
    described_class.call(
      invitation: invitation
    )
  end

  let!(:help_phone_number) { "0147200001" }
  let!(:phone_number) { "0782605941" }
  let!(:phone_number_formatted) { "+33782605941" }
  let!(:applicant) do
    create(
      :applicant,
      phone_number: phone_number,
      first_name: "John", last_name: "Doe", title: "monsieur"
    )
  end
  let!(:department) do
    create(
      :department,
      number: "26",
      name: "Drôme",
      region: "Auvergne-Rhône-Alpes"
    )
  end

  let!(:invitation) do
    create(
      :invitation,
      applicant: applicant, department: department, token: "123", help_phone_number: help_phone_number,
      link: "https://www.rdv-solidarites.fr/lieux?invitation_token=123", format: "sms"
    )
  end

  describe "#call" do
    let!(:content) do
      "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous "\
        "d'orientation. Pour choisir la date et l'horaire de votre premier RDV, cliquez sur le lien suivant "\
        "dans les 3 jours: http://www.rdv-insertion.fr/invitations/redirect?token=123\n"\
        "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le 0147200001."
    end

    before do
      allow(SendTransactionalSms).to receive(:call)
      allow(Rails).to receive_message_chain(:env, :production?).and_return(true)
      ENV['HOST'] = "www.rdv-insertion.fr"
    end

    it("is a success") { is_a_success }

    it "calls the send transactional service" do
      expect(SendTransactionalSms).to receive(:call)
        .with(phone_number_formatted: phone_number_formatted,
              sender_name: "Dept#{department.number}",
              content: content)
      subject
    end

    context "when the phone number is blank" do
      let!(:phone_number) { '' }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Le téléphone doit être renseigné"])
      end
    end

    context "when the phone number is not a mobile" do
      let!(:phone_number) { '0123456789' }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Le numéro de téléphone doit être un mobile"])
      end
    end

    context "when the phone number is not a metropolitan mobile" do
      let!(:phone_number) { '0692926878' }

      it("is a success") { is_a_success }
    end

    context "when the invitation format is not sms" do
      let!(:invitation) do
        create(:invitation, applicant: applicant, format: "email")
      end

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["Envoi de SMS alors que le format est email"])
      end
    end
  end
end
