describe RdvSolidaritesOauthToken do
  describe "#refresh!" do
    subject { oauth_token.refresh!(expired_api_token) }

    let!(:oauth_token) do
      create(:rdv_solidarites_oauth_token, api_token: "current-token", refresh_token: "current-refresh")
    end
    let(:expired_api_token) { "current-token" }
    let(:oauth_client) { instance_double(RdvSolidaritesOauthClient) }
    let(:access_token) { instance_double(OAuth2::AccessToken, token: "new-token", refresh_token: "new-refresh") }

    before do
      allow(RdvSolidaritesOauthClient).to receive(:new).and_return(oauth_client)
      allow(oauth_client).to receive(:refresh!).and_return(access_token)
    end

    it "updates the tokens with the refreshed ones" do
      subject
      expect(oauth_token.reload).to have_attributes(api_token: "new-token", refresh_token: "new-refresh")
    end

    context "when the token has already been refreshed by another process" do
      let(:expired_api_token) { "already-rotated-token" }

      it "does not refresh again" do
        subject
        expect(oauth_client).not_to have_received(:refresh!)
      end

      it "keeps the current tokens" do
        subject
        expect(oauth_token.reload).to have_attributes(api_token: "current-token", refresh_token: "current-refresh")
      end
    end
  end
end
