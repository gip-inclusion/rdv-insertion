describe StaticPagesController, type: :controller do
  render_views

  let!(:department) { create(:department) }
  let!(:agent) { create(:agent, departments: [department]) }

  describe "GET #welcome" do
    it "returns a success response" do
      get :welcome
      expect(response).to be_successful
    end
  end

  describe "GET #home" do
    context "when the user is not logged in" do
      it "redirects to the root_path" do
        get :home
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the user is logged in" do
      before do
        sign_in(agent)
      end

      it "redirects to the departments_path" do
        get :home
        expect(response).to redirect_to(departments_path)
      end
    end
  end
end
