describe RdvSolidaritesWebhooks::ProcessUserProfileJob, type: :job do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "user" => { "id" => rdv_solidarites_user_id },
      "organisation" => { "id" => rdv_solidarites_organisation_id }
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_user_id) { 22 }
  let!(:rdv_solidarites_organisation_id) { 18 }

  let!(:meta) do
    {
      "model" => "UserProfile",
      "event" => "destroyed"
    }.deep_symbolize_keys
  end

  let!(:applicant) do
    create(:applicant, rdv_solidarites_user_id: rdv_solidarites_user_id, organisations: [organisation])
  end

  let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id) }

  describe "#call" do
    before do
      allow(SoftDeleteApplicantJob).to receive(:perform_async)
    end

    it "enqueues a soft delete applicant job" do
      expect(SoftDeleteApplicantJob).to receive(:perform_async)
        .with(rdv_solidarites_user_id)
      subject
    end

    context "when the applicant has more than one organisation" do
      let!(:organisation2) { create(:organisation) }
      let!(:applicant) do
        create(:applicant, rdv_solidarites_user_id: rdv_solidarites_user_id,
                           organisations: [organisation, organisation2])
      end

      it "removes the organisation from the applicant" do
        subject
        expect(applicant.reload.organisations).to eq([organisation2])
      end

      it "does not enqueue a delete applicant job" do
        expect(SoftDeleteApplicantJob).not_to receive(:perform_async)
        subject
      end
    end

    context "when the applicant cannot be found" do
      let!(:applicant) do
        create(:applicant, rdv_solidarites_user_id: "some-id", organisations: [organisation])
      end

      it "does not remove the organisation from the applicant" do
        subject
        expect(applicant.reload.organisations).to eq([organisation])
      end

      it "does not enqueue a delete applicant job" do
        expect(SoftDeleteApplicantJob).not_to receive(:perform_async)
        subject
      end
    end

    context "when the organisation cannot be found" do
      let!(:organisation) do
        create(:organisation, rdv_solidarites_organisation_id: "some-orga")
      end

      it "does not remove the organisation from the applicant" do
        subject
        expect(applicant.reload.organisations).to eq([organisation])
      end

      it "does not enqueue a delete applicant job" do
        expect(SoftDeleteApplicantJob).not_to receive(:perform_async)
        subject
      end
    end

    context "when the event is not destroyed" do
      let!(:meta) do
        {
          "model" => "UserProfile",
          "event" => "updated"
        }.deep_symbolize_keys
      end

      it "does not remove the organisation from the applicant" do
        subject
        expect(applicant.reload.organisations).to eq([organisation])
      end

      it "does not enqueue a delete applicant job" do
        expect(SoftDeleteApplicantJob).not_to receive(:perform_async)
        subject
      end
    end
  end
end
