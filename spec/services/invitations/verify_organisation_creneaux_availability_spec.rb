describe Invitations::VerifyOrganisationCreneauxAvailability, type: :service do
  subject do
    described_class.call(organisation_id: organisation.id)
  end

  include_context "with all existing categories"

  let!(:organisation) { create(:organisation) }
  let!(:organisation_id) { organisation.id }
  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }
  let!(:rdv_context_without_creneau) { create(:rdv_context, motif_category: category_rsa_orientation) }
  let!(:rdv_context2_without_creneau) { create(:rdv_context, motif_category: category_rsa_orientation) }
  let!(:rdv_context_with_creneau) { create(:rdv_context, motif_category: category_rsa_accompagnement_sociopro) }
  let!(:rdv_context_with_referent_without_creneau) do
    create(:rdv_context, motif_category: category_rsa_accompagnement_social)
  end

  let!(:invitation_with_no_creneau) do
    create(
      :invitation,
      organisations: [organisation],
      link: "https://www.rdv-solidarites.fr/prendre_rdv?address=1RueTest&city_code=12255&departement=12&invitation_token=XIXR0X2T&latitude=44.0&longitude=2.0&motif_category_short_name=rsa_orientation&organisation_ids%5B%5D=#{organisation_id}&street_ban_id=12255_0070",
      format: "email",
      rdv_context: rdv_context_without_creneau
    )
  end
  let!(:invitation_with_no_creneau_relevant_params) do
    { :city_code => "12255",
      :address => "1RueTest",
      :latitude => "44.0",
      :longitude => "2.0",
      :departement => "12",
      :invitation_token => "XIXR0X2T",
      :motif_category_short_name => "rsa_orientation",
      :organisation_ids => [organisation_id.to_s],
      :street_ban_id => "12255_0070" }
  end
  let!(:invitation2_with_no_creneau) do
    create(
      :invitation,
      organisations: [organisation],
      link: "https://www.rdv-solidarites.fr/prendre_rdv?address=1bRueTest&city_code=12255&departement=12&invitation_token=ZIXR0X2T&latitude=44.0&longitude=2.0&motif_category_short_name=rsa_orientation&organisation_ids%5B%5D=#{organisation_id}&street_ban_id=12255_0070",
      format: "email",
      rdv_context: rdv_context2_without_creneau
    )
  end
  let!(:invitation2_with_no_creneau_relevant_params) do
    { :city_code => "12255",
      :address => "1bRueTest",
      :latitude => "44.0",
      :longitude => "2.0",
      :departement => "12",
      :invitation_token => "ZIXR0X2T",
      :motif_category_short_name => "rsa_orientation",
      :organisation_ids => [organisation_id.to_s],
      :street_ban_id => "12255_0070" }
  end
  let!(:invitation_with_creneau) do
    create(
      :invitation,
      organisations: [organisation],
      link: "https://www.rdv-solidarites.fr/prendre_rdv?address=2RueTest&city_code=12000&departement=12&invitation_token=JIXR0X2T&latitude=44.0&longitude=2.0&motif_category_short_name=rsa_accompagnement_sociopro&organisation_ids%5B%5D=#{organisation_id}&street_ban_id=12000_0000",
      format: "email",
      rdv_context: rdv_context_with_creneau
    )
  end
  let!(:invitation_with_creneau_relevant_params) do
    { :city_code => "12000",
      :address => "2RueTest",
      :latitude => "44.0",
      :longitude => "2.0",
      :departement => "12",
      :invitation_token => "JIXR0X2T",
      :motif_category_short_name => "rsa_accompagnement_sociopro",
      :organisation_ids => [organisation_id.to_s],
      :street_ban_id => "12000_0000" }
  end
  let!(:invitation_with_referent_without_creneau) do
    create(
      :invitation,
      organisations: [organisation],
      link: "https://www.rdv-solidarites.fr/prendre_rdv?address=3RueTest&city_code=10000&departement=12&invitation_token=UIXR0X2T&latitude=44.0&longitude=2.0&motif_category_short_name=rsa_accompagnement_sociopro&organisation_ids%5B%5D=#{organisation_id}&street_ban_id=12000_0000&referent_ids%5B%5D=1",
      format: "email",
      rdv_context: rdv_context_with_referent_without_creneau
    )
  end
  let!(:invitation_with_referent_without_creneau_relevant_params) do
    { :city_code => "10000",
      :address => "3RueTest",
      :latitude => "44.0",
      :longitude => "2.0",
      :departement => "12",
      :invitation_token => "UIXR0X2T",
      :motif_category_short_name => "rsa_accompagnement_sociopro",
      :organisation_ids => [organisation_id.to_s],
      :street_ban_id => "12000_0000",
      :referent_ids => ["1"] }
  end

  describe "#call" do
    before do
      allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call)
        .with(link_params: invitation_with_referent_without_creneau_relevant_params)
        .and_return(OpenStruct.new(success?: true, creneau_availability: false))
      allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call)
        .with(link_params: invitation_with_creneau_relevant_params)
        .and_return(OpenStruct.new(success?: true, creneau_availability: true))
      allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call)
        .with(link_params: invitation2_with_no_creneau_relevant_params)
        .and_return(OpenStruct.new(success?: true, creneau_availability: false))
      allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call)
        .with(link_params: invitation_with_no_creneau_relevant_params)
        .and_return(OpenStruct.new(success?: true, creneau_availability: false))
    end

    it "is a success" do
      is_a_success
    end

    context "with results" do
      let!(:result) { subject }

      it "returns the right result" do
        excepted_result = [
          {
            motif_category_name: "RSA orientation",
            city_codes: ["12255"],
            referent_ids: [],
            invitations_counter: 2
          },
          {
            motif_category_name: "RSA accompagnement socio-pro",
            city_codes: ["10000"],
            referent_ids: ["1"],
            invitations_counter: 1
          }
        ]
        expect(result.grouped_invitation_params_by_category).to eq(excepted_result)
      end
    end
  end
end
