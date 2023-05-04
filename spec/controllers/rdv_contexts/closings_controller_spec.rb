describe RdvContexts::ClosingsController do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:applicant) { create(:applicant, organisations: [organisation]) }
  let!(:rdv_context) { create(:rdv_context, applicant: applicant) }
  let!(:agent) { create(:agent, organisations: [organisation]) }

  before do
    sign_in(agent)
  end

  describe "#create" do
    before do
      allow(RdvContexts::Close).to receive(:call)
        .with(rdv_context: rdv_context)
        .and_return(OpenStruct.new(success?: true))
    end

    let(:create_params) do
      { rdv_context_id: rdv_context.id, applicant_id: applicant.id,
        organisation_id: organisation.id, department_id: department.id }
    end

    it "calls the close rdv_context service" do
      expect(RdvContexts::Close).to receive(:call)
        .with(rdv_context: rdv_context)
      post :create, params: create_params
    end

    context "when the rdv_context is closed successfully" do
      it "redirects to applicant show" do
        post :create, params: create_params
        expect(response).to redirect_to(department_applicant_path(department, applicant))
      end
    end

    context "when not department_level" do
      let(:create_params) do
        { rdv_context_id: rdv_context.id, applicant_id: applicant.id,
          organisation_id: organisation.id, department_id: nil }
      end

      context "when the rdv_context is closed successfully" do
        it "redirects to applicant show at organisation level" do
          post :create, params: create_params
          expect(response).to redirect_to(organisation_applicant_path(organisation, applicant))
        end
      end
    end
  end

  describe "#destroy" do
    let(:destroy_params) do
      { rdv_context_id: rdv_context.id, applicant_id: applicant.id,
        organisation_id: organisation.id, department_id: department.id }
    end
    let!(:rdv_context) { create(:rdv_context, applicant: applicant, status: "closed") }

    it "updates the rdv_context status" do
      post :destroy, params: destroy_params
      expect(rdv_context.reload.status).not_to eq("closed")
      expect(rdv_context.reload.closed_at).to eq(nil)
    end

    context "when the rdv_context is closed successfully" do
      it "redirects to applicant show" do
        post :destroy, params: destroy_params
        expect(response).to redirect_to(department_applicant_path(department, applicant))
      end
    end

    context "when not department_level" do
      let(:destroy_params) do
        { rdv_context_id: rdv_context.id, applicant_id: applicant.id,
          organisation_id: organisation.id, department_id: nil }
      end

      context "when the rdv_context is closed successfully" do
        it "redirects to applicant show at organisation level" do
          post :destroy, params: destroy_params
          expect(response).to redirect_to(organisation_applicant_path(organisation, applicant))
        end
      end
    end
  end
end
