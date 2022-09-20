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
    let(:create_params) do
      { archiving_reason: "something", applicant_id: applicant_id }
    end

    it "archives the applicant" do
      post :create, params: create_params
      expect(response).to be_successful
      expect(JSON.parse(response.body)["success"]).to eq(true)
      expect(applicant.reload.archived_at).to eq(now)
      expect(applicant.reload.archiving_reason).to eq("something")
    end

    context "when the applicant is archived" do
      let!(:rdv_context) do
        create(:rdv_context, applicant: applicant, motif_category: "rsa_orientation")
      end
      let!(:invitation1) do
        create(:invitation, valid_until: 3.days.from_now, rdv_context: rdv_context, applicant: applicant)
      end
      let!(:rdv_context2) do
        create(:rdv_context, applicant: applicant, motif_category: "rsa_accompagnement")
      end
      let!(:invitation2) do
        create(:invitation, valid_until: 3.days.from_now, rdv_context: rdv_context2, applicant: applicant)
      end

      before do
        allow(InvalidateInvitationJob).to receive(:perform_async)
      end

      it "calls the InvalidateInvitationJob for the applicants invitations" do
        expect(InvalidateInvitationJob).to receive(:perform_async).exactly(1).time.with(invitation1.id)
        expect(InvalidateInvitationJob).to receive(:perform_async).exactly(1).time.with(invitation2.id)
        post :create, params: create_params
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
  end
end
