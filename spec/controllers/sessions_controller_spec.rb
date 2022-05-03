describe SessionsController, type: :controller do
  render_views

  let!(:organisation) { create(:organisation) }
  let!(:agent_email) {  "agent@beta.gouv.fr" }
  let!(:agent) { create(:agent, email: agent_email, organisations: [organisation]) }

  describe "GET /sign_in" do
    it "renders the login form" do
      get :new
      expect(response).to be_successful
      expect(response.body).to match(/Identifiez-vous avec votre compte Agent de RDV-Solidarités/)
    end
  end

  describe "POST #create" do
    context "JSON" do
      let(:session_headers) do
        {
          "client" => "some-client",
          "uid" => agent_email,
          "access-token" => "some-token",
          "Content-Type" => "application/json",
          "Accept" => "application/json"
        }
      end
      let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }

      before do
        request.headers.merge(session_headers)
        allow(RdvSolidaritesSession).to receive(:new)
          .with(
            uid: session_headers["uid"], access_token: session_headers["access-token"],
            client: session_headers["client"]
          ).and_return(rdv_solidarites_session)
        allow(rdv_solidarites_session).to receive(:valid?)
          .and_return(true)
        allow(RdvSolidaritesApi::RetrieveOrganisations).to receive(:call)
          .with(rdv_solidarites_session: rdv_solidarites_session)
          .and_return(OpenStruct.new(success?: true, organisations: [organisation]))
        allow(UpsertAgent).to receive(:call)
          .with(email: agent_email, organisation_ids: [organisation.id])
          .and_return(OpenStruct.new(success?: true, agent: agent))
      end

      it "retrieves the agent organisations" do
        expect(RdvSolidaritesApi::RetrieveOrganisations).to receive(:call)
          .with(rdv_solidarites_session: rdv_solidarites_session)
        post :create
      end

      it "upserts the agent" do
        expect(UpsertAgent).to receive(:call)
          .with(email: session_headers["uid"], organisation_ids: [organisation.id])

        post :create
      end

      it "is a success" do
        post :create
        expect(response).to be_successful
        expect(JSON.parse(response.body)["success"]).to eq(true)
      end

      it "sets a session" do
        post :create
        expect(request.session[:agent_id]).to eq(agent.id)
        expect(request.session[:rdv_solidarites][:client]).to eq(session_headers["client"])
        expect(request.session[:rdv_solidarites][:uid]).to eq(session_headers["uid"])
        expect(request.session[:rdv_solidarites][:access_token]).to eq(session_headers["access-token"])
      end

      context "when a redirect path is in the session" do
        before do
          request.session[:agent_return_to] = "/some_path"
        end

        it "returns the redirection path" do
          post :create
          expect(response).to be_successful
          expect(JSON.parse(response.body)["redirect_path"]).to eq("/some_path")
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
          expect(JSON.parse(response.body)["redirect_path"]).to eq(organisations_path)
        end
      end

      context "when session is invalid" do
        before do
          allow(rdv_solidarites_session).to receive(:valid?)
            .and_return(false)
        end

        it "is a failure" do
          post :create
          expect(response).not_to be_successful
          expect(response.status).to eq(401)
          expect(JSON.parse(response.body)["errors"]).to eq(["Les identifiants de session RDV-Solidarités sont invalides"])
        end
      end

      context "when it fails to retrieve the organisations" do
        before do
          allow(RdvSolidaritesApi::RetrieveOrganisations).to receive(:call)
            .with(rdv_solidarites_session: rdv_solidarites_session)
            .and_return(OpenStruct.new(success?: false, errors: ["failure retrieving orgs"]))
        end

        it "is a failure" do
          post :create
          expect(response).not_to be_successful
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)["success"]).to eq(false)
          expect(JSON.parse(response.body)["errors"]).to eq(["failure retrieving orgs"])
        end
      end

      context "when it fails to upsert the agent" do
        before do
          allow(UpsertAgent).to receive(:call)
            .with(email: session_headers["uid"], organisation_ids: [organisation.id])
            .and_return(OpenStruct.new(success?: false, errors: ["failure upserting agent"]))
        end

        it "is a failure" do
          post :create
          expect(response).not_to be_successful
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)["success"]).to eq(false)
          expect(JSON.parse(response.body)["errors"]).to eq(["failure upserting agent"])
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
      expect(request.session[:agent_id]).to be_nil
    end

    it "redirects to root page" do
      delete :destroy
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to include("Déconnexion réussie")
    end
  end
end
