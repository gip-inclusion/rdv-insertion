describe DepartmentsController, type: :controller do
  render_views

  let!(:department) { create(:department) }
  let!(:department2) { create(:department) }
  let!(:agent) { create(:agent, departments: [department]) }
  let!(:agent2) { create(:agent, departments: [department, department2]) }

  describe "GET #index" do
    context "when agent is authorized" do
      context "and linked to one department" do
        before do
          sign_in(agent)
        end

        it "redirects to department_applicants_path" do
          get :index
          expect(response).to redirect_to(department_applicants_path(department))
        end
      end

      context "and linked to multiples departments" do
        before do
          sign_in(agent2)
        end

        it "returns a success response" do
          get :index
          expect(response).to be_successful
        end

        it "returns a list of departments" do
          get :index

          expect(response.body).to match(/#{department.name}/)
          expect(response.body).to match(/#{department2.name}/)
        end
      end
    end
  end
end
