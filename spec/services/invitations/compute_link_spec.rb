describe Invitations::ComputeLink, type: :service do
  subject do
    described_class.call(
      invitation: invitation
    )
  end

  let!(:department_number) { "75" }
  let!(:department) do
    create(
      :department,
      number: department_number,
      name: "Paris",
      region: "Ile-de-France"
    )
  end

  let(:address) { "20 avenue de ségur 75007 Paris" }

  let!(:applicant) do
    create(:applicant, address: address, department: department)
  end
  let!(:rdv_context) { build(:rdv_context, motif_category: "rsa_accompagnement") }
  let!(:invitation) do
    create(
      :invitation,
      department: department,
      organisations: [organisation1, organisation2],
      applicant: applicant,
      rdv_context: rdv_context,
      token: invitation_token
    )
  end

  let!(:organisation1) { create(:organisation, department: department, rdv_solidarites_organisation_id: 333) }
  let!(:organisation2) { create(:organisation, department: department, rdv_solidarites_organisation_id: 444) }

  let!(:invitation_token) { "sometoken" }

  describe "#call" do
    before do
      allow(RetrieveGeolocalisation).to receive(:call)
        .with(address: address, department_number: department_number)
        .and_return(
          OpenStruct.new(
            success?: true, longitude: 2.308628, latitude: 48.850699, city_code: "75107",
            street_ban_id: "75107_8909"
          )
        )

      ENV['RDV_SOLIDARITES_URL'] = 'https://www.rdv-solidarites.fr'
    end

    it("is a success") { is_a_success }

    it "returns the link" do
      expect(subject.invitation_link).to include(invitation_token)
    end

    it "computes the link" do
      expect(subject.invitation_link).to eq(
        "https://www.rdv-solidarites.fr/prendre_rdv?address=20+avenue+de+s%C3%A9gur+75007+Paris" \
        "&city_code=75107&departement=75&invitation_token=sometoken&latitude=48.850699&longitude=2.308628" \
        "&motif_category=rsa_accompagnement&organisation_ids%5B%5D=333&organisation_ids%5B%5D=444" \
        "&show_available_lieux_only=true&street_ban_id=75107_8909"
      )
    end

    context "retrieves geolocalisation" do
      it "tries to retrieve the geolocalisation" do
        expect(RetrieveGeolocalisation).to receive(:call)
          .with(
            address: address,
            department_number: department_number
          )
        subject
      end

      context "when it fails" do
        before do
          allow(RetrieveGeolocalisation).to receive(:call)
            .with(
              address: address,
              department_number: department_number
            )
            .and_return(OpenStruct.new(success?: false))
        end

        it("still succeeds") { is_a_success }

        it "does not add the attributes to the link" do
          expect(subject.invitation_link).to eq(
            "https://www.rdv-solidarites.fr/prendre_rdv?address=20+avenue+de+s%C3%A9gur+75007+Paris&" \
            "departement=75&invitation_token=sometoken&motif_category=rsa_accompagnement&" \
            "organisation_ids%5B%5D=333&organisation_ids%5B%5D=444&show_available_lieux_only=true"
          )
        end
      end
    end

    context "when a lieu id is passed" do
      let!(:invitation) do
        create(
          :invitation,
          department: department,
          organisations: [organisation1, organisation2],
          applicant: applicant,
          rdv_context: rdv_context,
          token: invitation_token,
          rdv_solidarites_lieu_id: 5
        )
      end

      it "does not retrieve the geolocalisation" do
        expect(RetrieveGeolocalisation).not_to receive(:call)
        subject
      end

      it "adds the lieu id instead of the geo attributes in the url" do
        expect(subject.invitation_link).to eq(
          "https://www.rdv-solidarites.fr/prendre_rdv?address=20+avenue+de+s%C3%A9gur+75007+Paris&" \
          "departement=75&invitation_token=sometoken&lieu_id=5&motif_category=rsa_accompagnement&" \
          "organisation_ids%5B%5D=333&organisation_ids%5B%5D=444&show_available_lieux_only=true"
        )
      end
    end
  end
end
