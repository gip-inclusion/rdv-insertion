describe Website::TeleprocedureLandingsController do
  render_views

  let!(:department) { create(:department, number: "13", name: "Bouches-du-Rhône") }

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { department_number: "13" }
      expect(response).to be_successful
      expect(response.body).to include("INFORMATION - RSA")
    end
  end
end
