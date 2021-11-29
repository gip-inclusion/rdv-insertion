describe RdvSolidaritesWebhooks::ProcessUserJob, type: :job do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "id" => rdv_solidarites_user_id,
      "first_name" => "John",
      "last_name" => "Doe",
      "phone_number_formatted" => "+33624242424"
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_user_id) { 22 }

  let!(:meta) do
    {
      "model" => "User",
      "event" => "updated"
    }.deep_symbolize_keys
  end

  let!(:applicant) { create(:applicant, rdv_solidarites_user_id: rdv_solidarites_user_id) }

  describe "#call" do
    before do
      allow(UpsertRecordJob).to receive(:perform_async)
      allow(DeleteApplicantJob).to receive(:perform_async)
    end

    it "enqueues upsert record job" do
      expect(UpsertRecordJob).to receive(:perform_async)
        .with("Applicant", data)
      subject
    end

    context "when the applicant is not found" do
      let!(:applicant) { create(:applicant, rdv_solidarites_user_id: "some-id") }

      it "does not enqueue a job" do
        expect(UpsertRecordJob).not_to receive(:perform_async)
        subject
      end
    end

    context "when it is a destroy event" do
      let!(:meta) do
        {
          "model" => "User",
          "event" => "destroyed"
        }.deep_symbolize_keys
      end

      it "enqueues a delete applicant job" do
        expect(DeleteApplicantJob).to receive(:perform_async)
          .with(rdv_solidarites_user_id)
        subject
      end
    end
  end
end
