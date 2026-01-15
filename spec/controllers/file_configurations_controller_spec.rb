describe FileConfigurationsController do
  let!(:organisation) { create(:organisation) }
  let!(:another_organisation) { create(:organisation) }
  let!(:category_configuration) { create(:category_configuration, organisation: organisation) }
  let!(:file_configuration) { create(:file_configuration, category_configurations: [category_configuration]) }
  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }
  let!(:unauthorized_agent) { create(:agent, admin_role_in_organisations: [another_organisation]) }

  render_views

  before do
    sign_in(agent)
    request.session[:organisation_id] = organisation.id
    request.session[:current_structure_type] = "organisation"
  end

  describe "#show" do
    let!(:show_params) { { id: file_configuration.id } }

    it "displays the file_configuration" do
      get :show, params: show_params

      expect(response).to be_successful
      expect(unescaped_response_body).to match(/Nom de l'onglet Excel/)
      expect(unescaped_response_body).to match(/#{file_configuration.sheet_name}/)
      expect(unescaped_response_body).to match(/Colonnes obligatoires/)
    end

    context "when not authorized because does not belong to the organisation" do
      let!(:unauthorized_agent) { create(:agent) }

      before do
        sign_in(unauthorized_agent)
      end

      it "redirects to the homepage" do
        get :show, params: show_params

        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authorized because not admin in the right organisation" do
      before do
        sign_in(unauthorized_agent)
      end

      it "redirects the agent" do
        get :show, params: show_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end
  end

  describe "#new" do
    it "displays the new form for file_configuration" do
      get :new

      expect(response).to be_successful
      expect(unescaped_response_body).to match(/Créer un nouveau modèle/)
      expect(unescaped_response_body).to match(/file_configuration\[sheet_name\]/)
    end
  end

  describe "#edit" do
    let!(:edit_params) { { id: file_configuration.id } }

    it "displays the edit form for file_configuration" do
      get :edit, params: edit_params

      expect(response).to be_successful
      expect(unescaped_response_body).to match(/Modifier le modèle de fichier/)
      expect(unescaped_response_body).to match(/file_configuration\[sheet_name\]/)
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
      before do
        sign_in(unauthorized_agent)
      end

      it "redirects the agent" do
        get :edit, params: edit_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end
  end

  describe "#create" do
    let!(:create_params) do
      {
        file_configuration: {
          sheet_name: "INDEX BENEFICIAIRES", title_column: "Civilité", first_name_column: "Prénom",
          last_name_column: "Nom", role_column: "Rôle", email_column: "Adresses mail"
        }
      }
    end

    it "creates the file category_configuration" do
      expect { post :create, params: create_params, format: :turbo_stream }.to change(FileConfiguration, :count).by(1)
    end

    it "assigns the corrects attributes" do
      post :create, params: create_params, format: :turbo_stream
      expect(FileConfiguration.last.reload.sheet_name).to eq("INDEX BENEFICIAIRES")
      expect(FileConfiguration.last.reload.title_column).to eq("Civilité")
      expect(FileConfiguration.last.reload.first_name_column).to eq("Prénom")
      expect(FileConfiguration.last.reload.last_name_column).to eq("Nom")
      expect(FileConfiguration.last.reload.role_column).to eq("Rôle")
      expect(FileConfiguration.last.reload.email_column).to eq("Adresses mail")
    end

    context "when the creation succeeds" do
      it "redirects to the category_configuration" do
        post :create, params: create_params, format: :turbo_stream
        expect(response).to be_successful
        expect(unescaped_response_body).to match(/Le modèle de fichier a été créé avec succès/)
      end
    end

    context "when the creation fails" do
      let!(:create_params) do
        {
          file_configuration: {
            sheet_name: "INDEX BENEFICIAIRES"
          }
        }
      end

      it "does not create the file_configuration" do
        expect { post :create, params: create_params, format: :turbo_stream }.not_to change(FileConfiguration, :count)
      end

      it "renders the new form" do
        post :create, params: create_params, format: :turbo_stream

        expect(unescaped_response_body).to match(/Prénom doit être rempli/)
        expect(unescaped_response_body).to match(/Nom de famille doit être rempli/)
      end
    end
  end

  describe "#update" do
    let!(:update_params) do
      {
        file_configuration: {
          sheet_name: "INDEX BENEFICIAIRES", title_column: "monsieurmadame", first_name_column: "Prénom",
          last_name_column: "Nom", role_column: "Rôle benef", email_column: "Adresses mail"
        },
        id: file_configuration.id
      }
    end

    it "updates the category_configuration" do
      patch :update, params: update_params, format: :turbo_stream
      expect(file_configuration.reload.sheet_name).to eq("INDEX BENEFICIAIRES")
      expect(file_configuration.reload.title_column).to eq("monsieurmadame")
      expect(file_configuration.reload.first_name_column).to eq("Prénom")
      expect(file_configuration.reload.last_name_column).to eq("Nom")
      expect(file_configuration.reload.role_column).to eq("Rôle benef")
      expect(file_configuration.reload.email_column).to eq("Adresses mail")
    end

    context "when the update succeeds" do
      it "is a success" do
        patch :update, params: update_params, format: :turbo_stream
        expect(response).to be_successful
        expect(unescaped_response_body).to match(/Le modèle de fichier a été modifié avec succès/)
      end
    end

    context "when the update fails" do
      let!(:update_params) do
        {
          file_configuration: {
            first_name_column: "", last_name_column: ""
          },
          id: file_configuration.id
        }
      end

      it "does not update the file_configuration" do
        patch :update, params: update_params, format: :turbo_stream
        expect(file_configuration.reload.first_name_column).not_to eq("")
        expect(file_configuration.reload.last_name_column).not_to eq("")
      end

      it "renders the edit page" do
        patch :update, params: update_params, format: :turbo_stream
        expect(unescaped_response_body).to match(/Prénom doit être rempli/)
        expect(unescaped_response_body).to match(/Nom de famille doit être rempli/)
      end
    end

    context "when not authorized because not admin" do
      let!(:unauthorized_agent) { create(:agent, basic_role_in_organisations: [organisation]) }

      before do
        sign_in(unauthorized_agent)
      end

      it "redirects to the homepage" do
        patch :update, params: update_params, format: :turbo_stream

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when not authorized because not admin in the right organisation" do
      let!(:unauthorized_agent) { create(:agent, admin_role_in_organisations: [another_organisation]) }

      before do
        sign_in(unauthorized_agent)
      end

      it "is forbidden" do
        patch :update, params: update_params, format: :turbo_stream
        expect(response).to have_http_status(:forbidden)
        expect(response.body.to_s).to include("Vous n'avez pas les droits")
      end
    end
  end
end
