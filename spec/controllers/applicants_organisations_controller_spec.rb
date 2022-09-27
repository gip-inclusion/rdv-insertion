describe ApplicantsOrganisationsController, type: :controller do
  let!(:applicant_id) { 2222 }
  let!(:applicant) { create(:applicant, id: applicant_id, organisations: [organisation1], department: department) }
  let!(:organisation1) { create(:organisation, name: "CD de DIE") }
  let(:organisation2) { create(:organisation, name: "CD de Valence") }
  let!(:department) { create(:department, organisations: [organisation1, organisation2]) }
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }
  let!(:agent) { create(:agent, organisations: [organisation1]) }

  render_views

  before do
    sign_in(agent)
    setup_rdv_solidarites_session(rdv_solidarites_session)
  end

  describe "#new" do
    it "shows the organisations selection" do
      get :new, params: { applicant_id: applicant_id, department_id: department.id }

      expect(response).to be_successful
      expect(response.body).to match(/CD de Valence/)
      expect(response.body).not_to match(/CD de DIE/)
    end
  end

  describe "#create" do
    subject do
      post :create, params: {
        applicant_id: applicant_id, department_id: department.id, applicants_organisation: {
          organisation_id: organisation2.id
        }, format: "turbo_stream"
      }
    end

    before do
      allow(Applicants::Save).to receive(:call)
        .with(applicant: applicant, organisation: organisation2, rdv_solidarites_session: rdv_solidarites_session)
        .and_return(OpenStruct.new(success?: true))
    end

    it "redirects with a success message" do
      subject

      expect(response).to be_successful
      expect(response.body).to match(/flashes/)
      expect(response.body).to match(/L&#39;allocataire a bien été ajouté à l&#39;organisation/)
    end

    it "saves the applicant with the organisation" do
      expect(Applicants::Save).to receive(:call)
        .with(applicant: applicant, organisation: organisation2, rdv_solidarites_session: rdv_solidarites_session)
      subject
    end

    context "when the save fails" do
      before do
        allow(Applicants::Save).to receive(:call)
          .with(applicant: applicant, organisation: organisation2, rdv_solidarites_session: rdv_solidarites_session)
          .and_return(OpenStruct.new(success?: false, errors: ["something failed"]))
      end

      it "redirects with an error message" do
        subject

        expect(response).to redirect_to(department_applicant_path(department, applicant))
        expect(flash[:error]).to include("something failed")
      end
    end
  end
end
