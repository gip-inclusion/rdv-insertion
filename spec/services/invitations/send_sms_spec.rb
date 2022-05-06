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
  let!(:configuration) { create(:configuration, context: "rsa_orientation") }
  let!(:organisation) { create(:organisation, configurations: [configuration], department: department) }

  let!(:invitation) do
    create(
      :invitation,
      applicant: applicant, department: department, token: "123", help_phone_number: help_phone_number,
      number_of_days_to_accept_invitation: 9, organisations: [organisation],
      link: "https://www.rdv-solidarites.fr/lieux?invitation_token=123", format: "sms", rdv_context: rdv_context
    )
  end

  let!(:rdv_context) { build(:rdv_context, context: "rsa_orientation") }
  let!(:content) do
    "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous "\
      "d'orientation. Pour choisir la date et l'horaire de votre premier RDV, cliquez sur le lien suivant "\
      "dans les 9 jours: http://www.rdv-insertion.fr/invitations/redirect?token=123\n"\
      "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le 0147200001."
  end

  describe "#call" do
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

    context "for rsa accompagnement" do
      let!(:rdv_context) { build(:rdv_context, context: "rsa_accompagnement") }
      let!(:configuration) { create(:configuration, context: "rsa_accompagnement") }
      let!(:organisation) { create(:organisation, configurations: [configuration], department: department) }

      let!(:invitation) do
        create(
          :invitation,
          applicant: applicant, department: department, token: "123", help_phone_number: help_phone_number,
          number_of_days_to_accept_invitation: 9, organisations: [organisation],
          link: "https://www.rdv-solidarites.fr/lieux?invitation_token=123", format: "sms", rdv_context: rdv_context
        )
      end
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez vous présenter à un rendez-vous "\
          "d'accompagnement. Pour choisir la date et l'horaire de votre premier RDV, cliquez sur le lien suivant "\
          "dans les 9 jours: http://www.rdv-insertion.fr/invitations/redirect?token=123\n"\
          "Ce rendez-vous est obligatoire. En cas de problème technique, contactez le 0147200001."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number_formatted: phone_number_formatted,
                sender_name: "Dept#{department.number}",
                content: content)
        subject
      end
    end

    context "for rsa orientation on phone platform" do
      let!(:rdv_context) { build(:rdv_context, context: "rsa_orientation_on_phone_platform") }
      let!(:configuration) { create(:configuration, context: "rsa_orientation_on_phone_platform") }
      let!(:organisation) { create(:organisation, configurations: [configuration], department: department) }

      let!(:invitation) do
        create(
          :invitation,
          applicant: applicant, department: department, token: "123", help_phone_number: help_phone_number,
          number_of_days_to_accept_invitation: 9, organisations: [organisation],
          link: "https://www.rdv-solidarites.fr/lieux?invitation_token=123", format: "sms", rdv_context: rdv_context
        )
      end
      let!(:content) do
        "Monsieur John DOE,\nVous êtes bénéficiaire du RSA et vous devez contacter la plateforme départementale " \
          "afin de démarrer votre parcours d’accompagnement. Pour cela, merci d’appeler le " \
          "0147200001 dans un délai de 9 jours. "\
          "Cet appel est nécessaire pour le traitement de votre dossier."
      end

      it("is a success") { is_a_success }

      it "calls the send transactional service with the right content" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number_formatted: phone_number_formatted,
                sender_name: "Dept#{department.number}",
                content: content)
        subject
      end
    end

    context "when the sms sender name is defined in organisation configuration" do
      let!(:configuration) { create(:configuration, context: "rsa_orientation", sms_sender_name: "PoleRSA") }
      let!(:organisation) { create(:organisation, configurations: [configuration], department: department) }

      let!(:invitation) do
        create(
          :invitation,
          applicant: applicant, department: department, token: "123", help_phone_number: help_phone_number,
          number_of_days_to_accept_invitation: 9, organisations: [organisation],
          link: "https://www.rdv-solidarites.fr/lieux?invitation_token=123", format: "sms", rdv_context: rdv_context
        )
      end

      it("is a success") { is_a_success }

      it "sends the SMS with the right sender name" do
        expect(SendTransactionalSms).to receive(:call)
          .with(phone_number_formatted: phone_number_formatted,
                sender_name: "PoleRSA",
                content: content)
        subject
      end
    end
  end
end
