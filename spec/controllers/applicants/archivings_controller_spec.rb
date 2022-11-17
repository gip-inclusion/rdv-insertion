describe Applicants::ArchivingsController, type: :controller do
  let!(:organisation) { create(:organisation) }
  let!(:applicant) { create(:applicant, id: applicant_id, organisations: [organisation]) }
  let!(:applicant_id) { 33 }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:archiving_params) { { archiving_reason: "something" } }
  let!(:now) { Time.zone.parse("2022-05-22") }

  before do
    travel_to(now)
    sign_in(agent)
  end

  describe "#create" do
    before do
      allow(Applicants::Archive).to receive(:call)
        .with(applicant: applicant, rdv_solidarites_session: rdv_solidarites_session,
              archiving_reason: "something")
        .and_return(OpenStruct.new(success?: true))
    end

    let(:create_params) do
      { archiving_reason: "something", applicant_id: applicant_id }
    end

    it "calls the archive applicants service" do
      expect(Applicants::Archive).to receive(:call)
        .with(applicant: applicant, rdv_solidarites_session: rdv_solidarites_session,
              archiving_reason: "something")
      post :create, params: create_params
    end

    context "when the archiving is successfull" do
      it "renders a successfull response" do
        post :create, params: create_params
        expect(response).to be_successful
        expect(JSON.parse(response.body)["success"]).to eq(true)
      end

      it "returns the applicant" do
        post :create, params: create_params
        expect(JSON.parse(response.body)["applicant"]).to be_present
      end
    end

    context "when the archiving is unsucessfull" do
      before do
        allow(Applicants::Archive).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["something failed"]))
      end

      it "renders the errors" do
        post :create, params: create_params

        expect(response).not_to be_successful
        expect(JSON.parse(response.body)["success"]).to eq(false)
        expect(JSON.parse(response.body)["errors"]).to eq(["something failed"])
      end
    end
  end

  describe "#destroy" do
    let!(:applicant) do
      create(
        :applicant, id: applicant_id, organisations: [organisation], archiving_reason: "something", archived_at: now
      )
    end

    it "unarchives the applicant" do
      delete :destroy, params: { applicant_id: applicant_id }
      expect(response).to be_successful
      expect(JSON.parse(response.body)["success"]).to eq(true)
      expect(applicant.reload.archived_at).to eq(nil)
      expect(applicant.reload.archiving_reason).to eq(nil)
    end

    it "returns the applicant" do
      post :destroy, params: { applicant_id: applicant_id }
      expect(JSON.parse(response.body)["applicant"]).to be_present
    end
  end
end
