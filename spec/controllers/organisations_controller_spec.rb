describe OrganisationsController do
  let!(:department) { create(:department) }
  let!(:organisation) do
    create(:organisation, name: "PIE Pantin", slug: "pie-pantin", email: "pie@pantin.fr", phone_number: "0102030405",
                          department: department)
  end
  let!(:organisation2) { create(:organisation, department: department) }
  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }
  let(:agent2) { create(:agent, organisations: [organisation, organisation2]) }

  render_views

  before do
    sign_in(agent)
  end

  describe "#index" do
    context "when agent is authorized" do
      context "and linked to one organisation" do
        it "redirects to organisation_users_path" do
          get :index
          expect(response).to redirect_to(default_list_organisation_users_path(organisation))
        end
      end

      context "and linked to multiples organisations" do
        before do
          sign_in(agent2)
        end

        it "returns a success response" do
          get :index
          expect(response).to be_successful
        end

        it "returns a list of organisations" do
          get :index

          expect(response.body).to match(/#{organisation.name}/)
          expect(response.body).to match(/#{organisation2.name}/)
        end
      end
    end
  end

  describe "#geolocated" do
    subject { get :geolocated, params: { department_number: department_number, address: address } }

    let!(:agent) { create(:agent, organisations: [organisation, organisation2]) }
    let!(:department) { create(:department, number: department_number) }
    let!(:organisation) { create(:organisation, department: department) }
    let!(:organisation2) do
      create(:organisation, department: department, rdv_solidarites_organisation_id: rdv_solidarites_id)
    end
    let!(:rdv_solidarites_id) { 999 }
    let!(:department_number) { "26" }
    let!(:address) { "20 avenue de la résistance 26150 Die" }
    let!(:city_code) { "26323" }
    let!(:street_ban_id) { "26444" }
    let!(:geo_attributes) do
      { departement_number: department_number, city_code: city_code, street_ban_id: street_ban_id }
    end
    let!(:rdv_solidarites_organisation) { RdvSolidarites::Organisation.new(id: rdv_solidarites_id) }

    before do
      sign_in(agent)
      allow(RetrieveAddressGeocodingParams).to receive(:call)
        .with(address: address, department_number: department.number)
        .and_return(
          OpenStruct.new(
            success?: true,
            geocoding_params: { city_code: city_code, street_ban_id: street_ban_id }
          )
        )
      allow(RdvSolidaritesApi::RetrieveOrganisations).to receive(:call)
        .and_return(OpenStruct.new(success?: true, organisations: [rdv_solidarites_organisation]))
    end

    it "is a success" do
      subject
      expect(response).to be_successful
      result = response.parsed_body
      expect(result["success"]).to eq(true)
    end

    it "returns the geolocated organisations along with all the organisations" do
      subject
      result = response.parsed_body
      expect(result["geolocated_organisations"].count).to eq(1)
      expect(result["geolocated_organisations"].pluck("id")).to contain_exactly(organisation2.id)
      expect(result["department_organisations"].count).to eq(2)
      expect(result["department_organisations"].pluck("id")).to contain_exactly(organisation.id, organisation2.id)
    end

    context "when attributed organisations are not in the agent scoped organisations" do
      let!(:agent) { create(:agent, organisations: [organisation]) }

      it "is a success" do
        subject
        expect(response).to be_successful
        result = response.parsed_body
        expect(result["success"]).to eq(true)
      end

      it "returns empty organisations attributed to sector" do
        subject
        result = response.parsed_body
        expect(result["geolocated_organisations"].count).to eq(0)
        expect(result["department_organisations"].count).to eq(1)
        expect(result["department_organisations"].pluck("id")).to contain_exactly(organisation.id)
      end
    end

    context "when it fails to retrieve the organisations" do
      before do
        allow(RdvSolidaritesApi::RetrieveOrganisations).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["some error"]))
      end

      it "is a failure" do
        subject
        expect(response).to be_successful
        result = response.parsed_body
        expect(result["success"]).to eq(false)
        expect(result["errors"]).to eq(["some error"])
      end

      it "still returns the department organisations" do
        subject

        expect(response).to be_successful
        result = response.parsed_body
        expect(result["success"]).to eq(false)
        expect(result["department_organisations"].count).to eq(2)
        expect(result["department_organisations"].pluck("id")).to contain_exactly(organisation.id, organisation2.id)
      end
    end

    context "when it fails to geolocate" do
      before do
        allow(RetrieveAddressGeocodingParams).to receive(:call)
          .and_return(OpenStruct.new(success?: false, failure?: true))
      end

      it "is a failure" do
        subject
        expect(response).to be_successful
        result = response.parsed_body
        expect(result["success"]).to eq(false)
        expect(result["errors"]).to eq(["Impossible de géolocaliser le bénéficiaire à partir de l'adresse donnée"])
      end

      it "still returns the department organisations" do
        subject

        expect(response).to be_successful
        result = response.parsed_body
        expect(result["department_organisations"].count).to eq(2)
        expect(result["department_organisations"].pluck("id")).to contain_exactly(organisation.id, organisation2.id)
      end
    end
  end

  describe "#search" do
    subject { get :search, params: { department_number: "93", search_terms: search_terms } }

    let!(:department) { create(:department, number: "93") }
    let!(:organisation) { create(:organisation, name: "Mission locale", department: department) }
    let!(:organisation2) { create(:organisation, name: "PIE", department: department) }
    let!(:search_terms) { "pie" }

    before do
      sign_in(agent2)
    end

    it "is a success" do
      subject
      expect(response).to be_successful
      result = response.parsed_body
      expect(result["success"]).to eq(true)
    end

    it "returns the matching organisations along with all the department organisations" do
      subject
      result = response.parsed_body
      expect(result["matching_organisations"].count).to eq(1)
      expect(result["matching_organisations"].pluck("id")).to contain_exactly(organisation2.id)
      expect(result["department_organisations"].count).to eq(2)
      expect(result["department_organisations"].pluck("id")).to contain_exactly(organisation.id, organisation2.id)
    end

    context "when the search term is a slug" do
      let!(:organisation) { create(:organisation, name: "Mission locale", department: department, slug: "ml123") }
      let!(:search_terms) { "ml123" }

      it "returns the matching organisations along with all the department organisations" do
        subject
        expect(response).to be_successful

        result = response.parsed_body
        expect(result["success"]).to eq(true)

        expect(result["matching_organisations"].count).to eq(1)
        expect(result["matching_organisations"].pluck("id")).to contain_exactly(organisation.id)
        expect(result["department_organisations"].count).to eq(2)
        expect(result["department_organisations"].pluck("id")).to contain_exactly(organisation.id, organisation2.id)
      end
    end
  end

  describe "#show_info" do
    it "renders the info partial" do
      get :show_info, params: { id: organisation.id }
      expect(response).to be_successful
    end
  end

  describe "#edit_info" do
    it "renders the info_form partial" do
      get :edit_info, params: { id: organisation.id }
      expect(response).to be_successful
    end
  end

  describe "#update_info" do
    context "when valid params" do
      before do
        allow_any_instance_of(Organisations::Update).to receive(:call).and_return(OpenStruct.new(success?: true))
      end

      it "updates the organisation" do
        patch :update_info, params: {
          id: organisation.id,
          organisation: { name: "Nouveau nom", phone_number: "0607080910" }
        }

        expect(response).to be_successful
      end
    end
  end

  describe "#show_data_retention" do
    it "renders the data_retention partial" do
      get :show_data_retention, params: { id: organisation.id }
      expect(response).to be_successful
    end
  end

  describe "#edit_data_retention" do
    it "renders the data_retention_form partial" do
      get :edit_data_retention, params: { id: organisation.id }
      expect(response).to be_successful
    end
  end

  describe "#update_data_retention" do
    let!(:admin_agent) { create(:agent, admin_role_in_organisations: [organisation]) }

    before do
      sign_in(admin_agent)
    end

    context "when valid duration" do
      it "updates the data retention duration" do
        patch :update_data_retention, params: {
          id: organisation.id,
          organisation: { data_retention_duration_in_months: 12 }
        }

        expect(response).to be_successful
        expect(organisation.reload.data_retention_duration_in_months).to eq(12)
      end
    end

    context "when invalid duration" do
      it "does not update" do
        patch :update_data_retention, params: {
          id: organisation.id,
          organisation: { data_retention_duration_in_months: 0 }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(organisation.reload.data_retention_duration_in_months).to eq(24)
      end
    end
  end
end
