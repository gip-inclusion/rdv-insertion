describe CarnetDeBord::CreateCarnet, type: :service do
  subject do
    described_class.call(applicant:, agent:, department:)
  end

  let!(:applicant) { create(:applicant, address: "20 avenue ségur") }
  let!(:department) { create(:department, carnet_de_bord_deploiement_id:, number: "93") }
  let!(:carnet_de_bord_deploiement_id) { "382A2" }
  let!(:agent) { create(:agent, email: "someone@gouv.fr") }
  let!(:expected_payload) do
    {
      rdviUserEmail: "someone@gouv.fr",
      deploymentId: "382A2",
      notebook: {
        nir: applicant.nir,
        externalId: applicant.department_internal_id,
        firstname: applicant.first_name,
        lastname: applicant.last_name,
        dateOfBirth: applicant.birth_date,
        mobileNumber: applicant.phone_number,
        email: applicant.email,
        cafNumber: applicant.affiliation_number,
        address1: "20 avenue de Ségur",
        postalCode: "75007",
        city: "Paris"
      }
    }
  end

  describe "#call" do
    before do
      allow(RetrieveGeolocalisation).to receive(:call).with(
        address: "20 avenue ségur", department_number: "93"
      ).and_return(OpenStruct.new(name: "20 avenue de Ségur", postcode: "75007", city: "Paris"))
      allow(CarnetDeBordClient).to receive(:create_carnet)
        .with(expected_payload)
        .and_return(OpenStruct.new(success?: true, body: { notebookId: "92119" }.to_json))
    end

    it "is a success" do
      is_a_success
    end

    it "assigns the carnet id" do
      subject
      expect(applicant.reload.carnet_de_bord_carnet_id).to eq("92119")
    end

    context "when the carnet creation fails" do
      before do
        allow(CarnetDeBordClient).to receive(:create_carnet)
          .with(expected_payload)
          .and_return(OpenStruct.new(success?: false, status: 401, body: { error: "Not authorized" }.to_json))
      end

      it "is a failure" do
        is_a_failure
      end

      it "returns an error" do
        expect(subject.errors).to eq(["Erreur en créant le carnet: Not authorized - 401"])
      end
    end

    context "when the department does not have a deploiement id" do
      before { department.update! carnet_de_bord_deploiement_id: nil }

      it "is a failure" do
        is_a_failure
      end

      it "returns an error" do
        expect(subject.errors).to eq(["le département 93 n'a pas d'ID de déploiement CdB"])
      end
    end

    context "when the applicant has a carnet id already assigned" do
      before { applicant.update! carnet_de_bord_carnet_id: "02012139" }

      it "is a failure" do
        is_a_failure
      end

      it "returns an error" do
        expect(subject.errors).to eq(["le carnet existe déjà pour la personne #{applicant.id}"])
      end
    end

    context "when the applicant does not have an adress" do
      let!(:applicant) { create(:applicant, address: nil) }
      let!(:expected_payload) do
        {
          rdviUserEmail: "someone@gouv.fr",
          deploymentId: "382A2",
          notebook: {
            nir: applicant.nir,
            externalId: applicant.department_internal_id,
            firstname: applicant.first_name,
            lastname: applicant.last_name,
            dateOfBirth: applicant.birth_date,
            mobileNumber: applicant.phone_number,
            email: applicant.email,
            cafNumber: applicant.affiliation_number
          }
        }
      end

      it "creates the carnet without the payload" do
        expect(CarnetDeBordClient).to receive(:create_carnet).with(expected_payload)
        subject
      end

      it "is a success" do
        is_a_success
      end
    end

    context "when the geolocalisation retrieval fails" do
      before do
        allow(RetrieveGeolocalisation).to receive(:call).with(
          address: "20 avenue ségur", department_number: "93"
        ).and_return(OpenStruct.new(failure?: true))
      end

      let!(:expected_payload) do
        {
          rdviUserEmail: "someone@gouv.fr",
          deploymentId: "382A2",
          notebook: {
            nir: applicant.nir,
            externalId: applicant.department_internal_id,
            firstname: applicant.first_name,
            lastname: applicant.last_name,
            dateOfBirth: applicant.birth_date,
            mobileNumber: applicant.phone_number,
            email: applicant.email,
            cafNumber: applicant.affiliation_number
          }
        }
      end

      it "creates the carnet without the payload" do
        expect(CarnetDeBordClient).to receive(:create_carnet).with(expected_payload)
        subject
      end

      it "is a success" do
        is_a_success
      end
    end
  end
end
