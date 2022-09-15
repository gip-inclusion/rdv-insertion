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
    it "is a success" do
      post :create, params: { archiving_reason: "something", applicant_id: applicant_id }
      expect(response).to be_successful
      expect(JSON.parse(response.body)["success"]).to eq(true)
      expect(applicant.reload.archived_at).to eq(now)
      expect(applicant.reload.archiving_reason).to eq("something")
    end
  end

  describe "#destroy" do
    let!(:applicant) do
      create(
        :applicant, id: applicant_id, organisations: [organisation], archiving_reason: "something", archived_at: now
      )
    end

    it "is a success" do
      delete :destroy, params: { applicant_id: applicant_id }
      expect(response).to be_successful
      expect(JSON.parse(response.body)["success"]).to eq(true)
      expect(applicant.reload.archived_at).to eq(nil)
      expect(applicant.reload.archiving_reason).to eq(nil)
    end
  end
end
