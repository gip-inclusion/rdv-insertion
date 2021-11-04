describe OrganisationsController, type: :controller do
  render_views

  let!(:organisation) { create(:organisation) }
  let!(:organisation2) { create(:organisation) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:agent2) { create(:agent, organisations: [organisation, organisation2]) }

  describe "GET #index" do
    context "when agent is authorized" do
      context "and linked to one organisation" do
        before do
          sign_in(agent)
        end

        it "redirects to organisation_applicants_path" do
          get :index
          expect(response).to redirect_to(organisation_applicants_path(organisation))
        end
      end

      context "and linked to multiples organisations" do
        before do
          sign_in(agent2)
        end

        it "returns a success response" do
          get :index
          expect(response).to be_successful
        end

        it "returns a list of organisations" do
          get :index

          expect(response.body).to match(/#{organisation.name}/)
          expect(response.body).to match(/#{organisation2.name}/)
        end
      end
    end
  end
end
