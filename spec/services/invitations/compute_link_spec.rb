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
      department: department
    )
  end

  let!(:invitation_token) { "sometoken" }
  let!(:rdv_solidarites_session) do
    { client: "client", uid: "johndoe@example.com", access_token: "token" }
  end

  describe "#call" do
    let!(:rdv_solidarites_client) { instance_double(RdvSolidaritesClient) }
    let!(:motifs) do
      [{
        "id" => 16,
        "location_type" => "public_office",
        "name" => "RSA - Orientation : rdv sur site"
      }]
    end

    before do
      allow(RdvSolidaritesClient).to receive(:new)
        .and_return(rdv_solidarites_client)
      allow(rdv_solidarites_client).to receive(:get_motifs)
        .and_return(OpenStruct.new(success?: true, body: { "motifs" => motifs }.to_json))
      allow(ENV).to receive(:[])
        .with('RDV_SOLIDARITES_URL')
        .and_return('https://www.rdv-solidarites.fr')
      allow(ENV).to receive(:[])
        .with('RDV_SOLIDARITES_RSA_SERVICE_ID')
        .and_return(4)
    end

    it("is a success") { is_a_success }

    it "returns the link" do
      expect(subject.invitation_link).to include(invitation_token)
    end

    context "retrieves the motif" do
      it "tries to retrieve the motifs" do
        expect(rdv_solidarites_client).to receive(:get_motifs)
          .with(27, 4)
        subject
      end

      context "when it fails" do
        before do
          allow(rdv_solidarites_client).to receive(:get_motifs)
            .and_return(OpenStruct.new(success?: false, body: { "errors" => ["something happened"] }.to_json))
        end

        it("is a failure") { is_a_failure }

        it "returns the error" do
          expect(subject.errors).to eq(["erreur RDV-Solidarités: [\"something happened\"]"])
        end
      end

      context "when no motifs is retrieved" do
        before do
          allow(rdv_solidarites_client).to receive(:get_motifs)
            .and_return(OpenStruct.new(success?: true, body: { "motifs" => [] }.to_json))
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
            "&search%5Bservice%5D=4&search%5Bwhere%5D=Dr%C3%B4me%2C+Auvergne-Rh%C3%B4ne-Alpes" \
            "&invitation_token=sometoken"
          )
        end
      end

      context "when several motifs are found" do
        let!(:motifs) do
          [
            {
              "id" => 16,
              "location_type" => "public_office",
              "name" => "RSA - Orientation : rdv sur site"
            },
            {
              "id" => 16,
              "location_type" => "phone",
              "name" => "RSA - Orientation : rdv telephonique"
            }
          ]
        end

        it "redirects to the motifs selection page" do
          expect(subject.invitation_link).to eq(
            "https://www.rdv-solidarites.fr/departement/26/4?where=Dr%C3%B4me%2C+Auvergne-Rh%C3%B4ne-Alpes" \
            "&invitation_token=sometoken"
          )
        end
      end
    end
  end
end
