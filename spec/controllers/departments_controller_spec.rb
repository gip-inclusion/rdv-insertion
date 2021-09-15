describe DepartmentsController, type: :controller do
  render_views

  let!(:department) { create(:department) }
  let!(:agent) { create(:agent, departments: [department]) }

  describe "GET #index" do
    before do
      sign_in(agent)
    end

    context "when agent is authorized" do
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
end
