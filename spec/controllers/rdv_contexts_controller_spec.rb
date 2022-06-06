describe RdvContextsController, type: :controller do
  let!(:applicant_id) { 2222 }
  let!(:department) { create(:department) }
  let!(:applicant) { create(:applicant, department: department, id: applicant_id) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:rdv_context) { create(:rdv_context, applicant: applicant, context: "rsa_accompagnement") }
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }

  render_views

  before do
    sign_in(agent)
    setup_rdv_solidarites_session(rdv_solidarites_session)
  end

  describe "#create" do
    subject do
      post :create, params: {
        applicant_id: applicant_id, rdv_context: {
          context: "rsa_accompagnement"
        }, format: "turbo_stream"
      }
    end

    before do
      allow(RdvContext).to receive(:find_or_initialize_by)
        .with(context: "rsa_accompagnement", applicant: applicant)
        .and_return(rdv_context)
      allow(rdv_context).to receive(:save)
        .and_return(true)
    end

    it "renders the success message" do
      subject

      expect(response).to be_successful
      expect(response.body).to match(/flashes/)
      expect(response.body).to match(/L&#39;allocataire a bien été ajouté au nouveau contexte/)
    end

    it "saves the applicant with the organisation" do
      expect(rdv_context).to receive(:save)
      subject
    end

    context "when the save fails" do
      before do
        allow(rdv_context).to receive(:save)
          .and_return(false)
        allow(rdv_context).to receive_message_chain(:errors, :full_messages, :to_sentence)
          .and_return('some error')
      end

      it "redirects with an error message" do
        subject

        expect(response).to redirect_to(department_applicant_path(department, applicant))
        expect(flash[:error]).to include("some error")
      end
    end
  end
end
