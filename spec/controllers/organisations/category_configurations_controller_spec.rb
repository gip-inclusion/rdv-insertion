describe Organisations::CategoryConfigurationsController do
  let!(:department) { create(:department) }
  let!(:organisation) do
    create(:organisation, name: "PIE Pantin", slug: "pie-pantin", email: "pie@pantin.fr", phone_number: "0102030405",
                          department: department)
  end
  let!(:another_organisation) { create(:organisation, department: department) }
  let!(:file_configuration) { create(:file_configuration) }
  let!(:category_configuration) do
    create(:category_configuration, organisation: organisation, file_configuration: file_configuration)
  end
  let!(:another_configuration) { create(:category_configuration, organisation: another_organisation) }
  let!(:config_of_other_dep) { create(:category_configuration, organisation: create(:organisation)) }
  let!(:messages_configuration) { create(:messages_configuration, organisation: organisation) }
  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }

  render_views

  before do
    sign_in(agent)
  end

  describe "#new" do
    let!(:new_configuration) { build(:category_configuration, organisation: organisation) }
    let!(:new_params) { { organisation_id: organisation.id } }

    it "renders the new category page" do
      get :new, params: new_params

      expect(response).to be_successful
      expect(response.body).to match(/Ajouter une catégorie/)
    end

    context "when not authorized because not admin" do
      let!(:unauthorized_agent) { create(:agent, basic_role_in_organisations: [organisation]) }

      before do
        sign_in(unauthorized_agent)
      end

      it "redirects to the homepage" do
        get :new, params: new_params

        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authorized because not admin in the right organisation" do
      let!(:unauthorized_agent) { create(:agent, admin_role_in_organisations: [another_organisation]) }

      before do
        sign_in(unauthorized_agent)
      end

      it "redirects the agent" do
        get :new, params: new_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end
  end

  describe "#create" do
    let!(:motif_category) { create(:motif_category) }
    let!(:create_params) do
      { category_configuration: category_configuration_attributes, organisation_id: organisation.id }
    end
    let!(:category_configuration_attributes) do
      {
        invitation_formats: %w[sms email postal], convene_user: false,
        rdv_with_referents: true, invite_to_user_organisations_only: true,
        number_of_days_before_invitations_expire: nil,
        motif_category_id: motif_category.id, file_configuration_id: file_configuration.id
      }
    end
    let!(:category_configuration) do
      create(:category_configuration, **category_configuration_attributes, organisation: organisation)
    end

    before do
      allow(CategoryConfigurations::Create).to receive(:call)
        .and_return(OpenStruct.new(success?: true, category_configuration: category_configuration))
      allow(CategoryConfiguration).to receive(:new).and_return(category_configuration)
    end

    it "tries to create the category_configuration" do
      expect(CategoryConfigurations::Create).to receive(:call)
        .with(category_configuration: category_configuration)
      post :create, params: create_params
    end

    context "when the creation succeeds" do
      it "is a success" do
        post :create, params: create_params
        expect(response).to redirect_to(organisation_configuration_categories_path(organisation))
      end
    end

    context "when the creation fails" do
      let!(:category_configuration) do
        build(:category_configuration, **category_configuration_attributes, organisation: organisation)
      end

      before do
        allow(CategoryConfigurations::Create).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors:
            ["Catégorie de motifs doit exister"]))
      end

      it "renders turbo_stream with error" do
        post :create, params: create_params
        expect(response).not_to be_successful
        expect(response).to have_http_status(:unprocessable_entity)
        expect(unescaped_response_body).to match(/error_list/)
        expect(unescaped_response_body).to match(/Catégorie de motifs doit exister/)
      end
    end

    context "when not authorized because not admin" do
      let!(:unauthorized_agent) { create(:agent, basic_role_in_organisations: [organisation]) }

      before do
        sign_in(unauthorized_agent)
      end

      it "redirects to the homepage" do
        post :create, params: create_params

        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authorized because not admin in the right organisation" do
      let!(:unauthorized_agent) { create(:agent, admin_role_in_organisations: [another_organisation]) }

      before do
        sign_in(unauthorized_agent)
      end

      it "redirects the agent" do
        post :create, params: create_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end
  end

  describe "#destroy" do
    let!(:destroy_params) do
      { organisation_id: organisation.id, id: category_configuration.id }
    end

    it "destroys the category_configuration" do
      expect do
        delete :destroy, params: destroy_params
        CategoryConfiguration.find(category_configuration.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when the destroy succeeds" do
      it "redirects with success flash" do
        delete :destroy, params: destroy_params
        expect(response).to redirect_to(organisation_configuration_categories_path(organisation))
        expect(flash[:success]).to eq("La configuration a été supprimée avec succès")
      end
    end

    context "when not authorized because not admin" do
      let!(:unauthorized_agent) { create(:agent, basic_role_in_organisations: [organisation]) }

      before do
        sign_in(unauthorized_agent)
      end

      it "redirects to the homepage" do
        delete :destroy, params: destroy_params

        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authorized because not admin in the right organisation" do
      let!(:unauthorized_agent) { create(:agent, admin_role_in_organisations: [another_organisation]) }

      before do
        sign_in(unauthorized_agent)
      end

      it "redirects the agent" do
        delete :destroy, params: destroy_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end
  end
end
