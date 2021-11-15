describe Invitations::ComputeLink, type: :service do
  subject do
    described_class.call(
      organisation: organisation, rdv_solidarites_session: rdv_solidarites_session,
      invitation_token: invitation_token, applicant: applicant
    )
  end

  let!(:department) do
    create(
      :department,
      number: "75",
      name: "Paris",
      region: "Ile-de-France"
    )
  end

  let!(:organisation) do
    create(
      :organisation,
      rdv_solidarites_organisation_id: 27,
      department: department,
      rsa_agents_service_id: "12"
    )
  end

  let(:address) { "20 avenue de ségur 75007 Paris" }

  let!(:applicant) do
    create(:applicant, address: address)
  end

  let!(:invitation_token) { "sometoken" }
  let!(:rdv_solidarites_session) do
    { client: "client", uid: "johndoe@example.com", access_token: "token" }
  end

  describe "#call" do
    let!(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }
    let!(:motifs) do
      [RdvSolidarites::Motif.new(
        "id" => 16,
        "location_type" => "public_office",
        "name" => "RSA - Orientation : rdv sur site"
      )]
    end

    before do
      allow(RdvSolidaritesClient).to receive(:new)
        .and_return(rdv_solidarites_client)
      allow(RdvSolidaritesApi::RetrieveMotifs).to receive(:call)
        .with(
          rdv_solidarites_session: rdv_solidarites_session,
          organisation: organisation
        )
        .and_return(OpenStruct.new(success?: true, motifs: motifs))
      allow(RetrieveGeolocalisation).to receive(:call)
        .with(address: address, department: department)
        .and_return(
          OpenStruct.new(
            success?: true, longitude: 2.308628, latitude: 48.850699, city_code: "75107",
            street_ban_id: "75107_8909"
          )
        )
      allow(ENV).to receive(:[])
        .with('RDV_SOLIDARITES_URL')
        .and_return('https://www.rdv-solidarites.fr')
    end

    it("is a success") { is_a_success }

    it "returns the link" do
      expect(subject.invitation_link).to include(invitation_token)
    end

    context "retrieves the motif" do
      it "tries to retrieve the motifs" do
        expect(RdvSolidaritesApi::RetrieveMotifs).to receive(:call)
          .with(
            rdv_solidarites_session: rdv_solidarites_session,
            organisation: organisation
          )
        subject
      end

      context "when it fails" do
        before do
          allow(RdvSolidaritesApi::RetrieveMotifs).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["something happened"]))
        end

        it("is a failure") { is_a_failure }

        it "returns the error" do
          expect(subject.errors).to eq(["something happened"])
        end
      end

      context "when no motifs is retrieved" do
        before do
          allow(RdvSolidaritesApi::RetrieveMotifs).to receive(:call)
            .and_return(OpenStruct.new(success?: true, motifs: []))
        end

        it("is a failure") { is_a_failure }

        it "returns the error" do
          expect(subject.errors).to eq(
            [
              "Aucun motif ne correspond aux critères d'invitation. Vérifiez que vous appartenez au bon service."
            ]
          )
        end
      end
    end

    context "retrieves geolocalisation" do
      it "tries to retrieve the geolocalisation" do
        expect(RetrieveGeolocalisation).to receive(:call)
          .with(
            address: address,
            department: department
          )
        subject
      end

      context "when it fails" do
        before do
          allow(RetrieveGeolocalisation).to receive(:call)
            .with(
              address: address,
              department: department
            )
            .and_return(OpenStruct.new(success?: false))
        end

        it("still succeeds") { is_a_success }

        it "does not add the attributes to the link" do
          expect(subject.invitation_link).to eq(
            "https://www.rdv-solidarites.fr/external_invitations/"\
            "organisations/27/services/12/motifs/16/lieux?departement=75&"\
            "invitation_token=sometoken&where=20+avenue+de+s%C3%A9gur+75007+Paris"
          )
        end
      end
    end

    context "computes the link" do
      context "when only one motif is found" do
        it "redirects to the lieux page with the motif id" do
          expect(subject.invitation_link).to eq(
            "https://www.rdv-solidarites.fr/external_invitations/organisations/27/services/12/motifs/16/lieux?" \
            "city_code=75107&departement=75&invitation_token=sometoken&latitude=48.850699&longitude=2.308628&" \
            "street_ban_id=75107_8909&where=20+avenue+de+s%C3%A9gur+75007+Paris" \
          )
        end
      end

      context "when several motifs are found" do
        let!(:motifs) do
          [
            RdvSolidarites::Motif.new(
              {
                "id" => 16,
                "location_type" => "public_office",
                "name" => "RSA - Orientation : rdv sur site"
              }
            ),
            RdvSolidarites::Motif.new(
              {
                "id" => 17,
                "location_type" => "phone",
                "name" => "RSA - Orientation : rdv telephonique"
              }
            )
          ]
        end

        it "redirects to the motifs selection page" do
          puts subject.invitation_link
          expect(subject.invitation_link).to eq(
            "https://www.rdv-solidarites.fr/external_invitations/organisations/27/services/12/motifs?" \
            "city_code=75107&departement=75&invitation_token=sometoken&latitude=48.850699&longitude=2.308628&"\
            "street_ban_id=75107_8909&where=20+avenue+de+s%C3%A9gur+75007+Paris" \
          )
        end
      end
    end
  end
end
