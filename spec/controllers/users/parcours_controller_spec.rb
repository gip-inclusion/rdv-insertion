describe Users::ParcoursController do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department, organisation_type: "delegataire_rsa") }
  let!(:agent) { create(:agent, basic_role_in_organisations: [organisation]) }
  let!(:user) { create(:user, organisations: [organisation]) }

  before { sign_in(agent) }

  describe "#show" do
    context "when authorized to access parcours" do
      it "renders the parcours page successfully" do
        get :show, params: { user_id: user.id, organisation_id: organisation.id }

        expect(response).to be_successful
        expect(response).to have_http_status(:ok)
      end
    end

    context "when not authorized to access parcours" do
      let!(:unauthorized_organisation) { create(:organisation, department: department) }
      let!(:unauthorized_user) { create(:user, organisations: [unauthorized_organisation]) }

      it "redirects with authorization error" do
        get :show, params: { user_id: unauthorized_user.id, organisation_id: unauthorized_organisation.id }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end

    context "when user no longer exists in the current organisation" do
      let(:user_from_another_organisation) { create(:user, organisations: [create(:organisation)]) }

      it "raises a not found error" do
        expect do
          get :show, params: { user_id: user_from_another_organisation.id, organisation_id: organisation.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when organization type doesn't have parcours access" do
      let!(:non_parcours_organisation) { create(:organisation, department: department, organisation_type: "autre") }
      let!(:non_parcours_agent) { create(:agent, basic_role_in_organisations: [non_parcours_organisation]) }
      let!(:non_parcours_user) { create(:user, organisations: [non_parcours_organisation]) }

      before { sign_in(non_parcours_agent) }

      it "redirects with authorization error" do
        get :show, params: { user_id: non_parcours_user.id, organisation_id: non_parcours_organisation.id }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end
  end
end
