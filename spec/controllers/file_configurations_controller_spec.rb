describe FileConfigurationsController do
  let!(:organisation) { create(:organisation) }
  let!(:configuration) { create(:configuration, organisations: [organisation]) }
  let!(:file_configuration) { create(:file_configuration, configurations: [configuration]) }
  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }

  render_views

  before do
    sign_in(agent)
  end

  describe "#show" do
    let!(:show_params) { { organisation_id: organisation.id, id: file_configuration.id } }

    it "displays the file_configuration" do
      get :show, params: show_params

      expect(response).to be_successful
      expect(response.body).to match(/Nom de l&#39;onglet Excel/)
      expect(response.body).to match(/#{file_configuration.sheet_name}/)
      expect(response.body).to match(/Colonnes obligatoires/)
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
      let!(:another_organisation) { create(:organisation) }
      let!(:unauthorized_agent) { create(:agent, admin_role_in_organisations: [another_organisation]) }

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
end
