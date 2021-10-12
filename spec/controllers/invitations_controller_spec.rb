describe InvitationsController, type: :controller do
  describe "#create" do
    let!(:applicant_id) { "24" }
    let!(:department) { create(:department) }
    let!(:agent) { create(:agent, departments: [department]) }
    let!(:applicant) { create(:applicant, department: department, id: applicant_id) }
    let!(:create_params) { { applicant_id: applicant_id, format: "sms" } }

    before do
      sign_in(agent)
      set_rdv_solidarites_session
      allow(Invitations::InviteApplicant).to receive(:call)
        .and_return(OpenStruct.new)
      allow(Applicant).to receive(:includes).and_return(Applicant)
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
          invitation_format: "sms"
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
    subject { get :redirect, params: invite_params }

    let!(:applicant_id) { "24" }
    let!(:department) { create(:department) }
    let!(:applicant) { create(:applicant, department: department, id: applicant_id) }
    let!(:invitation) { create(:invitation, applicant: applicant, format: "sms") }
    let!(:invitation2) { create(:invitation, applicant: applicant, format: "email") }

    context "when format is not specified" do
      let!(:invite_params) { { token: invitation.token } }

      it "marks the sms invitation as clicked" do
        subject
        expect(invitation.reload.clicked).to eq(true)
        expect(invitation2.reload.clicked).to eq(false)
      end

      it "redirects to the invitation link" do
        subject
        expect(response).to redirect_to invitation.link
      end
    end

    context "when format is specified" do
      let!(:invite_params) { { token: invitation.token, format: "email" } }

      it "marks the matching format invitation as clicked" do
        subject
        expect(invitation2.reload.clicked).to eq(true)
        expect(invitation.reload.clicked).to eq(false)
      end

      it "redirects to the invitation link" do
        subject
        expect(response).to redirect_to invitation2.link
      end
    end

    context "when no invitation is retrieved" do
      let!(:invitation) { create(:invitation, applicant: applicant, format: "email") }
      let!(:invite_params) { { token: invitation.token } }

      it "raises an error" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
