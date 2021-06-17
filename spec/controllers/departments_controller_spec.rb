describe DepartmentsController, type: :controller do
  render_views

  let!(:department) { create(:department) }
  let!(:agent) { create(:agent, department: department) }

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

  describe "GET #show" do
    before do
      sign_in(agent)
    end

    context "when department does not exist" do
      it "returns an error" do
        expect do
          get :show, params: { id: "i-do-not-exist" }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when agent does not belong to the department" do
      let(:other_department) { create(:department) }
      let(:agent) { create(:agent, department: other_department) }

      it "redirects the agent" do
        get :show, params: { id: department.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end

    context "when agent is authorized" do
      it "returns a success response" do
        get :show, params: { id: department.id }
        expect(response).to be_successful
      end
    end
  end
end
