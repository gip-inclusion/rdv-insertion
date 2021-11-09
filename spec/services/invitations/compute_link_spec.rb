describe Invitations::ComputeLink, type: :service do
  subject do
    described_class.call(
      organisation: organisation, rdv_solidarites_session: rdv_solidarites_session,
      invitation_token: invitation_token
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

  let!(:organisation) do
    create(
      :organisation,
      rdv_solidarites_organisation_id: 27,
      department: department,
      rsa_agents_service_id: "12"
    )
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

    context "computes the link" do
      context "when only one motif is found" do
        it "redirects to the lieux page with the motif params" do
          expect(subject.invitation_link).to eq(
            "https://www.rdv-solidarites.fr/lieux?" \
            "search%5Bdepartement%5D=26&" \
            "search%5Bmotif_name_with_location_type%5D=RSA+-+Orientation+%3A+rdv+sur+site-public_office"\
            "&search%5Bservice%5D=12&search%5Bwhere%5D=Dr%C3%B4me%2C+Auvergne-Rh%C3%B4ne-Alpes" \
            "&invitation_token=sometoken"
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
          expect(subject.invitation_link).to eq(
            "https://www.rdv-solidarites.fr/departement/26/12?where=Dr%C3%B4me%2C+Auvergne-Rh%C3%B4ne-Alpes" \
            "&invitation_token=sometoken"
          )
        end
      end
    end
  end
end
