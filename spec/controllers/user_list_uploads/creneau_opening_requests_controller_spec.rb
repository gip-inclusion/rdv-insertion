describe UserListUploads::CreneauOpeningRequestsController do
  let!(:organisation) { create(:organisation) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:user_list_upload) { create(:user_list_upload, agent: agent, structure: organisation) }

  before { sign_in(agent) }

  describe "#new" do
    context "when the agent does not own the upload" do
      let!(:other_agent) { create(:agent, organisations: [organisation]) }

      before { sign_in(other_agent) }

      it "denies access with a not-authorized flash" do
        get :new, params: { user_list_upload_id: user_list_upload.id, available_creneaux_count: 26 }

        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to eq("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end
  end
end
