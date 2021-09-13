describe Invitations::SendSms, type: :service do
  include Rails.application.routes.url_helpers

  subject do
    described_class.call(
      invitation: invitation
    )
  end

  let!(:phone_number_formatted) { "+33782605941" }
  let!(:applicant) do
    create(
      :applicant,
      phone_number_formatted: phone_number_formatted, department: department,
      first_name: "John", last_name: "Doe", title: "monsieur"
    )
  end
  let!(:department) do
    create(
      :department,
      rdv_solidarites_organisation_id: 27,
      number: "26",
      name: "Drôme",
      region: "Auvergne-Rhône-Alpes",
      phone_number: "0147200001"
    )
  end
  let!(:invitation) do
    create(:invitation, applicant: applicant, token: "123", link: "https://www.rdv-solidarites.fr/lieux?invitation_token=123")
  end

  describe "#call" do
    let!(:content) do
      "Monsieur John DOE,\nVous êtes allocataire du RSA. Vous bénéficiez d'un accompagnement personnalisé dans " \
        "le cadre de vos démarches d'insertion. Le département 26 (Drôme) " \
        "vous invite à prendre rendez-vous sans tarder, afin de choisir l'horaire qui vous convient le mieux, " \
        "à l'adresse suivante : " \
        "http://www.rdv-insertion.fr/invitations/redirect?token=123\n" \
        "Pour tout problème ou difficultés pour prendre RDV, contactez le secrétariat au 0147200001." \
        " Ce RDV est obligatoire, en cas d'absence une sanction pourra être prononcée."
    end

    before do
      allow(SendTransactionalSms).to receive(:call)
      ENV['HOST'] = "www.rdv-insertion.fr"
    end

    it("is a success") { is_a_success }

    it "calls the send transactional service" do
      expect(SendTransactionalSms).to receive(:call)
        .with(phone_number: phone_number_formatted, content: content)
      subject
    end

    context "when the phone number is blank" do
      let!(:phone_number_formatted) { '' }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["le téléphone doit être renseigné"])
      end
    end
  end
end
