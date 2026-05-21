describe SessionsController do
  render_views

  let!(:organisation) { create(:organisation) }
  let!(:agent_email) { "agent@beta.gouv.fr" }
  let!(:agent) { create(:agent, email: agent_email, organisations: [organisation], last_sign_in_at: nil) }
  let!(:timestamp) { Time.zone.now }

  describe "POST #create" do
    let(:request_headers) do
      {
        "omniauth.auth" => {
          "credentials" => {
            "token" => "some-token"
          },
          "info" => {
            "agent" => {
              "email" => agent_email
            }
          }
        }
      }
    end

    before do
      request.headers.merge(request_headers)
    end

    it "marks the agent as logged in" do
      post :create
      expect(agent.reload.last_sign_in_at).not_to be_nil
    end

    it "generates a new session key for the agent" do
      expect { post :create }.to(change { agent.reload.session_key })
    end

    it "sets a session" do
      post :create

      expect(request.session[:agent_auth]).to eq(
        {
          id: agent.id,
          created_at: timestamp.to_i,
          origin: "sign_in_form",
          signature: agent.reload.sign_with(timestamp.to_i),
          session_key: agent.reload.session_key
        }
      )
    end

    context "when it fails to retrieve the agent" do
      let!(:agent) { create(:agent, email: "someotheremail@beta.gouv.fr", organisations: [organisation]) }

      it "is a failure" do
        post :create
        expect(response).not_to be_successful
        expect(flash[:error]).to include(
          "L'agent ne fait pas partie d'une organisation sur RDV-Insertion"
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
        expect(flash[:error]).to include("Update impossible")
        expect(response).to redirect_to(root_url)
        expect(request.session[:agent_auth]).to be_nil
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

    it "redirects to rdv-solidarités sign out" do
      delete :destroy
      expect(response).to redirect_to(/www.rdv-solidarites-test/)
    end

    it "sets a flash notice indicating the session expired" do
      delete :destroy
      expect(flash[:notice]).to eq("Votre session a expirée, veuillez vous reconnecter")
    end

    context "when the sign out is agent-initiated" do
      it "does not set a flash notice" do
        delete :destroy, params: { agent_initiated: "true" }
        expect(flash[:notice]).to be_nil
      end
    end

    context "when there is no session at all" do
      before { request.session.delete("agent_auth") }

      it "sets a flash notice prompting to connect" do
        delete :destroy
        expect(flash[:notice]).to eq("Veuillez vous connecter")
      end
    end

    context "when the agent is a super admin" do
      let!(:agent) { create(:agent, :super_admin_verified) }

      it "invalidates the super admin authentication request" do
        delete :destroy
        expect(agent.reload.last_super_admin_authentication_request.invalidated_at).to be_present
      end
    end

    context "when the agent is impersonated by a super admin" do
      let!(:super_admin) { create(:agent, :super_admin_verified) }

      before do
        timestamp = Time.zone.now.to_i
        request.session["agent_auth"] = {
          id: agent.id,
          origin: "impersonate",
          created_at: timestamp,
          signature: agent.sign_with(timestamp),
          session_key: agent.session_key,
          super_admin_auth: {
            id: super_admin.id,
            origin: "sign_in_form",
            created_at: timestamp,
            signature: super_admin.sign_with(timestamp),
            session_key: super_admin.session_key
          }
        }
      end

      it "invalidates the super admin authentication request" do
        delete :destroy
        expect(super_admin.reload.last_super_admin_authentication_request.invalidated_at).to be_present
      end
    end
  end
end
