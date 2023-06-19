describe OrganisationsController do
  let!(:department) { create(:department) }
  let!(:organisation) do
    create(:organisation, name: "PIE Pantin", slug: "pie-pantin", email: "pie@pantin.fr", phone_number: "0102030405",
                          independent_from_cd: true, department: department)
  end
  let!(:organisation2) { create(:organisation, department: department) }
  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation], super_admin: true) }
  let(:agent2) { create(:agent, organisations: [organisation, organisation2]) }

  render_views

  before do
    sign_in(agent)
  end

  describe "#index" do
    context "when agent is authorized" do
      context "and linked to one organisation" do
        it "redirects to organisation_applicants_path" do
          get :index
          expect(response).to redirect_to(organisation_applicants_path(organisation))
        end

        context "with only one motif_category" do
          let!(:category_orientation) do
            create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
          end
          let!(:configuration) do
            create(:configuration, motif_category: category_orientation, organisation: organisation)
          end

          it "redirects to the motif_category index of the organisation" do
            get :index
            expect(response).to redirect_to(
              organisation_applicants_path(organisation, motif_category_id: category_orientation.id)
            )
          end
        end

        context "with multiples motif_categories" do
          let!(:category_orientation) do
            create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
          end
          let!(:category_accompagnement) do
            create(:motif_category, short_name: "rsa_accompagnement", name: "RSA accompagnement")
          end
          let!(:configuration) do
            create(:configuration, motif_category: category_orientation, organisation: organisation)
          end
          let!(:configuration2) do
            create(:configuration, motif_category: category_accompagnement, organisation: organisation)
          end

          it "redirects to the organisation_applicants_path" do
            get :index
            expect(response).to redirect_to(organisation_applicants_path(organisation))
          end
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

        context "when agent is not super admin" do
          it "does not display the create organisation button" do
            expect(response.body).not_to match("Lier une organisation RDVS")
          end
        end
      end
    end

    context "when agent is super admin" do
      let!(:agent) { create(:agent, admin_role_in_organisations: [organisation, organisation2], super_admin: true) }

      before do
        sign_in(agent)
      end

      it "displays the create organisation button" do
        get :index
        expect(response.body).to match("Lier une organisation RDVS")
      end
    end
  end

  describe "#show" do
    let!(:show_params) { { id: organisation.id } }

    it "displays the organisation" do
      get :show, params: show_params

      expect(response).to be_successful
      expect(response.body).to match(/Nom/)
      expect(response.body).to match(/PIE Pantin/)
      expect(response.body).to match(/Email/)
      expect(response.body).to match(/pie@pantin.fr/)
      expect(response.body).to match(/Numéro de téléphone/)
      expect(response.body).to match(/0102030405/)
      expect(response.body).to match(/Indépendante du CD/)
      expect(response.body).to match(/Oui/)
      expect(response.body).to match(/Logo/)
      expect(response.body).to match(%r{images/logos/pie-pantin})
      expect(response.body).to match(/Désignation dans le fichier allocataires/)
      expect(response.body).to match(/pie-pantin/)
    end

    context "when not authorized because not admin" do
      let!(:unauthorized_agent) { create(:agent, basic_role_in_organisations: [organisation]) }

      before do
        sign_in(unauthorized_agent)
      end

      it "redirects to the homepage" do
        get :show, params: show_params

        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authorized because not admin in the right organisation" do
      let!(:unauthorized_agent) { create(:agent, admin_role_in_organisations: [organisation2]) }

      before do
        sign_in(unauthorized_agent)
      end

      it "raises an error" do
        expect do
          get :show, params: show_params
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#new" do
    let!(:new_params) { { department_id: department.id } }

    it "displays the new organisation form" do
      get :new, params: new_params

      expect(response).to be_successful
      expect(response.body).to match(/ID de l'orga RDVS/)
      expect(response.body).to match(/Enregistrer/)
    end

    context "when not authorized because not super admin" do
      let!(:unauthorized_agent) { create(:agent, super_admin: false) }

      before do
        sign_in(unauthorized_agent)
      end

      it "redirects to the homepage" do
        get :new, params: new_params

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "#edit" do
    let!(:edit_params) { { id: organisation.id } }

    it "displays the organisation" do
      get :edit, params: edit_params

      expect(response).to be_successful
      expect(response.body).to match(/Nom/)
      expect(response.body).to match(/PIE Pantin/)
      expect(response.body).to match(/Email/)
      expect(response.body).to match(/pie@pantin.fr/)
      expect(response.body).to match(/Numéro de téléphone/)
      expect(response.body).to match(/0102030405/)
      expect(response.body).to match(/Indépendante du CD/)
      expect(response.body).to match(/Oui/)
      expect(response.body).to match(/Logo/)
      expect(response.body).to match(%r{images/logos/pie-pantin})
      expect(response.body).to match(/Désignation dans le fichier allocataires/)
      expect(response.body).to match(/pie-pantin/)
    end

    context "when not authorized because not admin" do
      let!(:unauthorized_agent) { create(:agent, basic_role_in_organisations: [organisation]) }

      before do
        sign_in(unauthorized_agent)
      end

      it "redirects to the homepage" do
        get :edit, params: edit_params

        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authorized because not admin in the right organisation" do
      let!(:unauthorized_agent) { create(:agent, admin_role_in_organisations: [organisation2]) }

      before do
        sign_in(unauthorized_agent)
      end

      it "raises an error" do
        expect do
          get :edit, params: edit_params
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#create" do
    let!(:create_params) do
      { department_id: department.id,
        organisation: { rdv_solidarites_organisation_id: organisation.rdv_solidarites_organisation_id } }
    end

    before do
      allow(Organisations::Create).to receive(:call)
        .and_return(OpenStruct.new(success?: true, organisation: organisation))
      allow(Organisation).to receive(:new)
        .and_return(organisation)
    end

    it "calls the create organisation service" do
      expect(Organisations::Create).to receive(:call)
        .with(organisation: organisation, current_agent: agent, rdv_solidarites_session: rdv_solidarites_session)

      post :create, params: create_params
    end

    context "when the create succeeds" do
      it "redirects to the orgnisation show page" do
        post :create, params: create_params

        expect(response).to redirect_to(organisation_applicants_path(organisation))
      end
    end

    context "when not authorized because not super admin" do
      let!(:unauthorized_agent) { create(:agent, super_admin: false) }

      before do
        sign_in(unauthorized_agent)
      end

      it "redirects to the homepage" do
        post :create, params: create_params

        expect(response).to redirect_to(root_path)
      end
    end

    context "when the organisation_id given is not correct" do
      let!(:create_params) do
        { department_id: department.id,
          organisation: { rdv_solidarites_organisation_id: "test" } }
      end

      before do
        allow(Organisations::Create).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors:
            ["L'ID de l'organisation RDV-Solidarités n'a pas été renseigné correctement"]))
      end

      it "renders the new form with the errors" do
        post :create, params: create_params

        expect(unescaped_response_body).to match(/ID de l'orga RDVS/)
        expect(unescaped_response_body).to match(
          /L'ID de l'organisation RDV-Solidarités n'a pas été renseigné correctement/
        )
      end
    end
  end

  describe "#update" do
    let!(:update_organisation_attributes) do
      {
        name: "PIE Romainville", slug: "pie-romainville", email: "pie@romainville.fr", phone_number: "0105040302",
        independent_from_cd: false
      }
    end
    let!(:update_params) { { id: organisation.id, organisation: update_organisation_attributes } }

    before do
      allow(Organisations::Update).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
    end

    it "calls the update organisation service" do
      expect(Organisations::Update).to receive(:call)
        .with(organisation: organisation, rdv_solidarites_session: rdv_solidarites_session)
      patch :update, params: update_params
    end

    context "when the update succeeds" do
      it "renders to the show page" do
        patch :update, params: update_params
        expect(response).to be_successful
        expect(response.body).not_to match(/input/)
      end
    end

    context "when the creation fails" do
      before do
        allow(Organisations::Update).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["some error"]))
      end

      it "renders the edit form" do
        patch :update, params: update_params
        expect(response).not_to be_successful
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match(/input/)
        expect(response.body).to match(/edit_organisation/)
      end
    end

    context "when not authorized because not admin" do
      let!(:unauthorized_agent) { create(:agent, basic_role_in_organisations: [organisation]) }

      before do
        sign_in(unauthorized_agent)
      end

      it "redirects to the homepage" do
        patch :update, params: update_params

        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authorized because not admin in the right organisation" do
      let!(:unauthorized_agent) { create(:agent, admin_role_in_organisations: [organisation2]) }

      before do
        sign_in(unauthorized_agent)
      end

      it "raises an error" do
        expect do
          patch :update, params: update_params
        end.to raise_error(ActiveRecord::RecordNotFound)
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
      allow(RetrieveGeolocalisation).to receive(:call)
        .with(address: address, department_number: department.number)
        .and_return(OpenStruct.new(success?: true, city_code: city_code, street_ban_id: street_ban_id))
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
        allow(RetrieveGeolocalisation).to receive(:call)
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
end
