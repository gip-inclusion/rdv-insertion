describe StaticPagesController, type: :controller do
  render_views

  describe "GET #welcome" do
    it "returns a success response" do
      get :welcome
      expect(response).to be_successful
    end
  end
end
