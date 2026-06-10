describe CreneauOpeningRequestsController do
  let!(:creneau_opening_request) { create(:creneau_opening_request) }

  describe "#redirect_shortcut" do
    subject { get :redirect_shortcut, params: { id: creneau_opening_request.id } }

    it "redirects to the long redirect path with the id" do
      subject

      expect(response).to redirect_to(redirect_creneau_opening_requests_path(id: creneau_opening_request.id))
    end
  end

  describe "#redirect" do
    subject { get :redirect, params: { id: creneau_opening_request.id } }

    it "stamps clicked_at on the request" do
      expect { subject }
        .to change { creneau_opening_request.reload.clicked_at }.from(nil)
    end

    it "redirects to the stored RDV-Solidarités link" do
      subject

      expect(response).to redirect_to(creneau_opening_request.link)
    end

    context "when the id does not exist" do
      subject { get :redirect, params: { id: "UNKNOWN1" } }

      it "redirects to root with an error flash" do
        subject

        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to be_present
      end
    end
  end
end
