describe Agent::RdvSolidaritesClient do
  describe "#rdv_solidarites_client" do
    subject { agent.rdv_solidarites_client }

    let(:agent) { create(:agent) }

    before { allow(RdvSolidaritesClient).to receive(:new) }

    it "authenticates with the agent oauth token" do
      subject
      expect(RdvSolidaritesClient).to have_received(:new).with(
        authentication: an_instance_of(RdvSolidaritesAuthentication::Oauth)
      )
    end
  end
end
