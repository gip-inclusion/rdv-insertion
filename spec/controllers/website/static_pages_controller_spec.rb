describe Website::StaticPagesController do
  render_views

  let!(:organisation) { create(:organisation) }
  let!(:agent) { create(:agent, organisations: [organisation]) }

  describe "GET #welcome" do
    it "returns a success response" do
      get :welcome
      expect(response).to be_successful
    end

    context "when the user is logged in" do
      before do
        sign_in(agent)
      end

      it "redirects to the organisations_path" do
        get :welcome
        expect(response).to redirect_to(organisations_path)
      end
    end
  end

  describe "GET #accessiblity" do
    it "returns a success response" do
      get :accessibility
      expect(response).to be_successful
      expect(response.body).to match(/Déclaration d'accessibilité?/)
    end
  end

  describe "GET #privacy_policy" do
    it "returns a success response" do
      get :privacy_policy
      expect(response).to be_successful
      expect(response.body).to match(/Qui est responsable de rdv-insertion ?/)
    end
  end

  describe "GET #legal_notice" do
    it "returns a success response" do
      get :legal_notice
      expect(response).to be_successful
      expect(response.body).to match(/Le site rdv-insertion est édité par le Groupement d’intérêt public/)
    end
  end

  describe "GET #cgu" do
    it "returns a success response" do
      get :cgu
      expect(response).to be_successful
      expect(response.body).to match(/CONDITIONS GENERALES D'UTILISATION/)
    end

    context "when accessing a specific version" do
      it "returns a success response for a valid version" do
        get :cgu, params: { version: "2023_02_09" }
        expect(response).to be_successful
        expect(response.body).to match(/CONDITIONS GENERALES D'UTILISATION/)
        expect(response.body).to match(/Version du 09 février 2023/)
      end

      it "returns a 404 for an invalid version" do
        expect do
          get :cgu, params: { version: "invalid_version" }
        end.to raise_error(ActionController::RoutingError, "Not Found")
      end
    end

    context "when accessing previous versions" do
      it "displays a list of all available versions" do
        get :cgu
        expect(response.body).to match(/Toutes les versions des CGU/)
        expect(response.body).to match(/Version du 09 février 2023/)
        expect(response.body).to match(/Version du 01 février 2023/)
      end
    end
  end
end
