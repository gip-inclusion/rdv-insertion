describe SessionsController do
  render_views

  let!(:organisation) { create(:organisation) }
  let!(:agent_email) { "agent@beta.gouv.fr" }
  let!(:agent) { create(:agent, email: agent_email, organisations: [organisation], last_sign_in_at: nil) }
  let!(:rdv_solidarites_credentials) { instance_double(RdvSolidaritesCredentials) }
  let!(:timestamp) { Time.zone.now }

  describe "POST #create" do
    context "JSON" do
      let(:request_headers) do
        {
          "client" => "some-client",
          "uid" => agent_email,
          "access-token" => "some-token",
          "Content-Type" => "application/json",
          "Accept" => "application/json"
        }
      end

      before do
        request.headers.merge(request_headers)
        allow(RdvSolidaritesCredentials).to receive(:new)
          .and_return(rdv_solidarites_credentials)
        allow(rdv_solidarites_credentials).to receive_messages(valid?: true, uid: agent_email, email: agent_email)
      end

      it "is a success" do
        post :create
        expect(response).to be_successful
        expect(response.parsed_body["success"]).to eq(true)
      end

      it "marks the agent as logged in" do
        post :create

        expect(response).to be_successful
        expect(agent.reload.last_sign_in_at).not_to be_nil
      end

      it "sets a session" do
        post :create

        expect(response).to be_successful
        expect(request.session[:agent_auth]).to eq(
          {
            id: agent.id,
            created_at: timestamp.to_i,
            origin: "sign_in_form",
            signature: agent.sign_with(timestamp.to_i)
          }
        )
      end

      context "when a redirect path is in the session" do
        before do
          request.session[:agent_return_to] = "/some_path"
        end

        it "returns the redirection path" do
          post :create
          expect(response).to be_successful
          expect(response.parsed_body["redirect_path"]).to eq("/some_path")
        end

        it "deletes the path from the session" do
          post :create
          expect(response).to be_successful
          expect(request.session[:agent_return_to]).to be_nil
        end
      end

      context "when no redirect path is in the session" do
        before do
          request.session[:agent_return_to] = nil
        end

        it "returns the organisations path" do
          post :create
          expect(response).to be_successful
          expect(response.parsed_body["redirect_path"]).to eq(root_path)
        end
      end

      context "when credentials are invalid" do
        before do
          allow(rdv_solidarites_credentials).to receive(:valid?)
            .and_return(false)
        end

        it "is a failure" do
          post :create
          expect(response).not_to be_successful
          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body["errors"]).to eq(
            ["Les identifiants de session RDV-Solidarités sont invalides"]
          )
          expect(request.session[:agent_auth]).to be_nil
        end
      end

      context "when it fails to retrieve the agent" do
        let!(:agent) { create(:agent, email: "someotheremail@beta.gouv.fr", organisations: [organisation]) }

        it "is a failure" do
          post :create
          expect(response).not_to be_successful
          expect(response).to have_http_status(:forbidden)
          expect(response.parsed_body["success"]).to eq(false)
          expect(response.parsed_body["errors"]).to eq(
            ["L'agent ne fait pas partie d'une organisation sur RDV-Insertion"]
          )
          expect(request.session[:agent_auth]).to be_nil
        end
      end

      context "when it fails to mark the agent as logged in" do
        before do
          allow(Agent).to receive(:find_by).and_return(agent)
          allow(agent).to receive(:update).and_return(false)
          allow(agent).to receive_message_chain(:errors, :full_messages)
            .and_return(["Update impossible"])
        end

        it "is a failure" do
          post :create
          expect(response).not_to be_successful
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["success"]).to eq(false)
          expect(response.parsed_body["errors"]).to eq(["Update impossible"])
          expect(request.session[:agent_auth]).to be_nil
        end
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      sign_in(agent)
    end

    it "clears the session" do
      delete :destroy
      expect(request.session[:agent_auth]).to be_nil
    end

    it "redirects to root page" do
      delete :destroy
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("Déconnexion réussie")
    end
  end
end
