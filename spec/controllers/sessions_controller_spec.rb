describe SessionsController, type: :controller do
  render_views

  let(:organisation) { create(:organisation) }
  let(:agent) { create(:agent, organisations: [organisation]) }

  describe "GET /sign_in" do
    it "renders the login form" do
      get :new
      expect(response).to be_successful
      expect(response.body).to match(/Identifiez-vous avec votre compte Agent de RDV-Solidarités/)
    end
  end

  describe "POST #create" do
    context "JSON" do
      let(:session_params) do
        { client: "some-client", uid: "some-uid", access_token: "some-token", organisation_ids: ["some-id"] }
      end

      before do
        allow(FindOrCreateAgent).to receive(:call)
          .and_return(OpenStruct.new)
      end

      it "calls the service" do
        expect(FindOrCreateAgent).to receive(:call)
          .with(email: session_params[:uid], organisation_ids: session_params[:organisation_ids])

        post :create, params: session_params.merge(format: 'json')
      end

      context "when the agent is found or created" do
        before do
          allow(FindOrCreateAgent).to receive(:call)
            .with(email: session_params[:uid], organisation_ids: session_params[:organisation_ids])
            .and_return(OpenStruct.new(success?: true, agent: agent))
        end

        it "is a success" do
          post :create, params: session_params.merge(format: 'json')
          expect(response).to be_successful
          expect(JSON.parse(response.body)["success"]).to eq(true)
        end

        it "sets a session" do
          post :create, params: session_params.merge(format: 'json')
          expect(request.session[:agent_id]).to eq(agent.id)
          expect(request.session[:rdv_solidarites][:client]).to eq(session_params[:client])
          expect(request.session[:rdv_solidarites][:uid]).to eq(session_params[:uid])
          expect(request.session[:rdv_solidarites][:access_token]).to eq(session_params[:access_token])
        end

        context "when a redirect path is in the session" do
          before do
            request.session[:agent_return_to] = "/some_path"
          end

          it "returns the redirection path" do
            post :create, params: session_params.merge(format: 'json')
            expect(response).to be_successful
            expect(JSON.parse(response.body)["redirect_path"]).to eq("/some_path")
          end

          it "deletes the path from the session" do
            post :create, params: session_params.merge(format: 'json')
            expect(response).to be_successful
            expect(request.session[:agent_return_to]).to be_nil
          end
        end

        context "when no redirect path is in the session" do
          before do
            request.session[:agent_return_to] = nil
          end

          it "returns the organisations path" do
            post :create, params: session_params.merge(format: 'json')
            expect(response).to be_successful
            expect(JSON.parse(response.body)["redirect_path"]).to eq(organisations_path)
          end
        end
      end

      context "when the agent is not found nor created" do
        before do
          allow(FindOrCreateAgent).to receive(:call)
            .with(email: session_params[:uid], organisation_ids: session_params[:organisation_ids])
            .and_return(OpenStruct.new(success?: false))
        end

        it "is not a success" do
          post :create, params: session_params.merge(format: 'json')
          expect(response).to be_successful
          expect(JSON.parse(response.body)["success"]).to eq(false)
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
