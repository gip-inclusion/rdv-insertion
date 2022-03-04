describe StaticPagesController, type: :controller do
  render_views

  let!(:department) { create(:department, number: "13", name: "Bouches-du-Rhône") }
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
    end
  end

  describe "GET #privacy_policy" do
    it "returns a success response" do
      get :privacy_policy
      expect(response).to be_successful
    end
  end

  describe "GET #legal_notice" do
    it "returns a success response" do
      get :legal_notice
      expect(response).to be_successful
    end
  end

  describe "GET #teleprocedure" do
    it "returns a success response" do
      get :teleprocedure, params: { to: "static_pages#teleprocedure", department_number: "13" }
      expect(response).to be_successful
    end
  end
end
