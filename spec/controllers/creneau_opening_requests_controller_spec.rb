describe CreneauOpeningRequestsController do
  let!(:creneau_opening_request) { create(:creneau_opening_request) }

  describe "#redirect_shortcut" do
    subject { get :redirect_shortcut, params: { uuid: creneau_opening_request.uuid } }

    it "redirects to the long redirect path with the uuid" do
      subject

      expect(response).to redirect_to(redirect_creneau_opening_requests_path(uuid: creneau_opening_request.uuid))
    end
  end

  describe "#redirect" do
    subject { get :redirect, params: { uuid: creneau_opening_request.uuid } }

    it "stamps clicked_at on the request" do
      expect { subject }
        .to change { creneau_opening_request.reload.clicked_at }.from(nil)
    end

    it "redirects to the stored RDV-Solidarités link" do
      subject

      expect(response).to redirect_to(creneau_opening_request.link)
    end

    context "when the uuid does not exist" do
      subject { get :redirect, params: { uuid: "UNKNOWN1" } }

      it "redirects to root with an error flash" do
        subject

        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to be_present
      end
    end
  end
end
