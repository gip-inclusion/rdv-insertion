describe Agent::RdvSolidaritesClient do
  describe "#rdv_solidarites_client" do
    subject { agent.rdv_solidarites_client }

    let(:agent) { create(:agent) }

    before { allow(RdvSolidaritesClient).to receive(:new) }

    context "when the agent has an oauth token" do
      before { create(:rdv_solidarites_oauth_token, agent: agent) }

      it "authenticates with the oauth token" do
        subject
        expect(RdvSolidaritesClient).to have_received(:new).with(
          authentication: an_instance_of(RdvSolidaritesAuthentication::Oauth)
        )
      end
    end

    context "when the agent has no oauth token" do
      it "authenticates with the shared secret" do
        subject
        expect(RdvSolidaritesClient).to have_received(:new).with(
          authentication: an_instance_of(RdvSolidaritesAuthentication::SharedSecret)
        )
      end
    end
  end
end
