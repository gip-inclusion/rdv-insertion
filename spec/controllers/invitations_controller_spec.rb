describe InvitationsController, type: :controller do
  describe "#create" do
    let!(:applicant_id) { "24" }
    let!(:department) { create(:department) }
    let!(:agent) { create(:agent, departments: [department]) }
    let!(:configuration) { create(:configuration, department: department) }
    let!(:applicant) { create(:applicant, department: department, id: applicant_id) }
    let!(:create_params) { { applicant_id: applicant_id } }

    before do
      sign_in(agent)
      set_rdv_solidarites_session
      allow(Invitations::InviteApplicant).to receive(:call)
        .and_return(OpenStruct.new)
      allow(Applicant).to receive(:find)
        .and_return(applicant)
    end

    it "retrieves the applicant" do
      expect(Applicant).to receive(:find)
        .with(applicant_id)
      post :create, params: create_params
    end

    it "calls the service" do
      expect(Invitations::InviteApplicant).to receive(:call)
        .with(
          applicant: applicant,
          rdv_solidarites_session: request.session[:rdv_solidarites],
          invitation_format: configuration.invitation_format
        )
      post :create, params: create_params
    end

    context "when the service succeeds" do
      let(:invitation) { create(:invitation, applicant: applicant) }

      before do
        allow(Invitations::InviteApplicant).to receive(:call)
          .and_return(OpenStruct.new(success?: true, invitation: invitation))
      end

      it "is a success" do
        post :create, params: create_params
        expect(response).to be_successful
        expect(JSON.parse(response.body)["success"]).to eq(true)
      end

      it "renders the invitation" do
        post :create, params: create_params
        expect(response).to be_successful
        expect(JSON.parse(response.body)["invitation"]["id"]).to eq(invitation.id)
      end
    end

    context "when the service fails" do
      before do
        allow(Invitations::InviteApplicant).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ['some error']))
      end

      it "is not a success" do
        post :create, params: create_params
        expect(response).to be_successful
        expect(JSON.parse(response.body)["success"]).to eq(false)
      end

      it "renders the errors" do
        post :create, params: create_params
        expect(response).to be_successful
        expect(JSON.parse(response.body)["errors"]).to eq(['some error'])
      end
    end
  end

  describe "#redirect" do
    let!(:applicant_id) { "24" }
    let!(:department) { create(:department) }
    let!(:applicant) { create(:applicant, department: department, id: applicant_id) }
    let!(:invitation) { create(:invitation, applicant: applicant) }
    let!(:invite_params) { { token: invitation.token } }

    it "mark the invitation as seen" do
      get :redirect, params: invite_params
      expect(invitation.reload.seen).to eq(true)
    end

    it "redirects to the invitation link" do
      get :redirect, params: invite_params
      expect(response).to redirect_to invitation.link
    end
  end
end
