describe ApplicantsOrganisationsController do
  let!(:applicant_id) { 2222 }
  let!(:applicant) { create(:applicant, id: applicant_id, organisations: [organisation1]) }
  let!(:organisation1) { create(:organisation, name: "CD de DIE") }
  let(:organisation2) { create(:organisation, name: "CD de Valence") }
  let!(:department) { create(:department, organisations: [organisation1, organisation2]) }
  let!(:agent) { create(:agent, organisations: [organisation1]) }

  render_views

  before do
    sign_in(agent)
  end

  describe "#create" do
    subject do
      post :create, params: {
        department_id: department.id, applicants_organisation: {
          organisation_id: organisation2.id, applicant_id: applicant_id
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

      expect(response).to redirect_to(department_applicant_path(department, applicant))
      expect(flash[:success]).to include("L'organisation a bien été ajoutée")
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

        expect(response.body).to match(/flashes/)
        expect(unescaped_response_body).to match(/something failed/)
      end
    end
  end

  describe "#destroy" do
    subject do
      delete :destroy, params: {
        department_id: department.id, applicants_organisation: {
          organisation_id: organisation1.id, applicant_id: applicant_id
        }, format: "turbo_stream"
      }
    end

    before do
      allow(Applicants::RemoveFromOrganisation).to receive(:call)
        .with(applicant: applicant, organisation: organisation1, rdv_solidarites_session: rdv_solidarites_session)
        .and_return(OpenStruct.new(success?: true))
    end

    it "shows with a success message" do
      subject

      expect(response).to be_successful
      expect(response.body).to match(/flashes/)
      expect(unescaped_response_body).to match(/L'organisation a bien été retirée/)
    end

    it "saves the applicant with the organisation" do
      expect(Applicants::RemoveFromOrganisation).to receive(:call)
        .with(applicant: applicant, organisation: organisation1, rdv_solidarites_session: rdv_solidarites_session)
      subject
    end

    context "when the save fails" do
      before do
        allow(Applicants::RemoveFromOrganisation).to receive(:call)
          .with(applicant: applicant, organisation: organisation1, rdv_solidarites_session: rdv_solidarites_session)
          .and_return(OpenStruct.new(success?: false, errors: ["something failed"]))
      end

      it "shows with an error message" do
        subject

        expect(response.body).to match(/flashes/)
        expect(unescaped_response_body).to match(/something failed/)
      end
    end
  end
end
