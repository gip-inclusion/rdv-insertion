describe DepartmentsController, type: :controller do
  render_views

  let!(:department) { create(:department) }

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "returns a list of departments" do
      get :index

      expect(response.body).to match(/#{department.name}/)
    end
  end
end
