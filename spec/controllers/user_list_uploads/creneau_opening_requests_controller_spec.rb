describe UserListUploads::CreneauOpeningRequestsController do
  let!(:organisation) { create(:organisation) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:user_list_upload) { create(:user_list_upload, agent: agent, structure: organisation) }
  let!(:recipient_agent) { create(:agent, organisations: [organisation]) }

  render_views

  before { sign_in(agent) }

  describe "#new" do
    subject(:perform_action) do
      get :new, params: {
        user_list_upload_id: user_list_upload.id,
        available_creneaux_count: 26,
        users_to_invite_count: 30
      }
    end

    it "responds successfully" do
      perform_action

      expect(response).to be_successful
    end

    it "renders the modal with the counts and recipient agent names" do
      perform_action

      expect(response.body).to include("26 créneaux disponibles")
      expect(response.body).to include("30 usagers à inviter")
      expect(response.body).to include(recipient_agent.to_s)
    end

    context "when the upload is at department level" do
      let!(:department) { create(:department, organisations: [organisation]) }
      let!(:user_list_upload) { create(:user_list_upload, agent: agent, structure: department) }

      it "lists agents of the department's organisations" do
        perform_action

        expect(response.body).to include(recipient_agent.to_s)
      end
    end

    context "when the agent is not the owner of the upload" do
      let!(:other_agent) { create(:agent, organisations: [organisation]) }

      before { sign_in(other_agent) }

      it "redirects with a not-authorized flash" do
        perform_action

        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "#create_many" do
    subject(:perform_action) do
      post :create_many, params: {
        user_list_upload_id: user_list_upload.id,
        available_creneaux_count: 26,
        users_to_invite_count: 30,
        recipient_agent_ids: [recipient_agent.id],
        format: "turbo_stream"
      }
    end

    before { ENV["CRENEAU_OPENING_REQUEST_TALLY_ID"] = "xxxxx" }

    it "creates one CreneauOpeningRequest per recipient" do
      expect { perform_action }.to change(CreneauOpeningRequest, :count).by(1)
    end

    it "renders the confirmation with a Tally feedback popup" do
      perform_action

      expect(unescape_html(response.body))
        .to include("Demande d'ouverture de créneaux envoyée")
        .and include('data-controller="tally"')
        .and include('data-tally-form-id="xxxxx"')
    end

    context "when no recipient is selected" do
      subject(:perform_action) do
        post :create_many, params: {
          user_list_upload_id: user_list_upload.id,
          available_creneaux_count: 26,
          recipient_agent_ids: [],
          format: "turbo_stream"
        }
      end

      it "does not create any CreneauOpeningRequest" do
        expect { perform_action }.not_to change(CreneauOpeningRequest, :count)
      end

      it "renders the error message inline" do
        perform_action

        expect(response.body).to include("Aucun agent destinataire sélectionné")
      end
    end
  end
end
