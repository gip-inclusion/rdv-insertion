describe UploadsController, type: :controller do
  let!(:department) { create(:department) }
  let!(:agent) { create(:agent, departments: [department]) }

  describe "GET #new" do
    before do
      sign_in(agent)
    end

    context "when department does not exist" do
      it "returns an error" do
        expect do
          get :new, params: { department_id: "i-do-not-exist" }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when agent does not belong to the department" do
      let(:other_department) { create(:department) }
      let(:agent) { create(:agent, departments: [other_department]) }

      it "redirects the agent" do
        get :new, params: { department_id: department.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end

    context "when agent is authorized" do
      it "returns a success response" do
        get :new, params: { department_id: department.id }
        expect(response).to be_successful
      end
    end
  end
end
