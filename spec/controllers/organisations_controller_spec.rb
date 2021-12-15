describe OrganisationsController, type: :controller do
  describe "GET #index" do
    render_views
    let!(:agent) { create(:agent, organisations: [organisation]) }
    let!(:agent2) { create(:agent, organisations: [organisation, organisation2]) }
    let!(:organisation) { create(:organisation) }
    let!(:organisation2) { create(:organisation) }

    context "when agent is authorized" do
      context "and linked to one organisation" do
        before do
          sign_in(agent)
        end

        it "redirects to organisation_applicants_path" do
          get :index
          expect(response).to redirect_to(organisation_applicants_path(organisation))
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

  describe "GET #geolocated" do
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
      set_rdv_solidarites_session
      allow(RetrieveGeolocalisation).to receive(:call)
        .with(address: address, department: department)
        .and_return(OpenStruct.new(success?: true, city_code: city_code, street_ban_id: street_ban_id))
      allow(RdvSolidaritesApi::RetrieveOrganisations).to receive(:call)
        .with(
          rdv_solidarites_session: request.session[:rdv_solidarites],
          geo_attributes: geo_attributes
        ).and_return(OpenStruct.new(success?: true, organisations: [rdv_solidarites_organisation]))
    end

    it "is a success" do
      subject
      expect(response).to be_successful
      result = JSON.parse(response.body)
      expect(result["success"]).to eq(true)
    end

    it "returns the geolocated organisations along with all the organisations" do
      subject
      result = JSON.parse(response.body)
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
        result = JSON.parse(response.body)
        expect(result["success"]).to eq(true)
      end

      it "returns empty organisations attributed to sector" do
        subject
        result = JSON.parse(response.body)
        expect(result["geolocated_organisations"].count).to eq(0)
        expect(result["department_organisations"].count).to eq(1)
        expect(result["department_organisations"].pluck("id")).to contain_exactly(organisation.id)
      end
    end

    context "when it fails to retrieve the organisations" do
      before do
        allow(RdvSolidaritesApi::RetrieveOrganisations).to receive(:call)
          .with(
            rdv_solidarites_session: request.session[:rdv_solidarites],
            geo_attributes: geo_attributes
          ).and_return(OpenStruct.new(success?: false, errors: ["some error"]))
      end

      it "is a failure" do
        subject
        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result["success"]).to eq(false)
        expect(result["errors"]).to eq(["some error"])
      end

      it "still returns the department organisations" do
        subject

        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result["success"]).to eq(false)
        expect(result["department_organisations"].count).to eq(2)
        expect(result["department_organisations"].pluck("id")).to contain_exactly(organisation.id, organisation2.id)
      end
    end

    context "when it fails to geolocate" do
      before do
        allow(RetrieveGeolocalisation).to receive(:call)
          .and_return(OpenStruct.new(success?: false, failure?: true))
      end

      it "is a failure" do
        subject
        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result["success"]).to eq(false)
        expect(result["errors"]).to eq(["Impossible de géolocaliser le bénéficiaire à partir de l'adresse donnée"])
      end

      it "still returns the department organisations" do
        subject

        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result["department_organisations"].count).to eq(2)
        expect(result["department_organisations"].pluck("id")).to contain_exactly(organisation.id, organisation2.id)
      end
    end
  end
end
