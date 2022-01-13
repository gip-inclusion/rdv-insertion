describe RdvSolidaritesWebhooks::ProcessOrganisationJob, type: :job do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "id" => rdv_solidarites_organisation_id,
      "name" => "CD 28",
      "email" => "contact@cd28.fr",
      "phone_number" => "+33624242424"
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_organisation_id) { 22 }

  let!(:meta) do
    {
      "model" => "Organisation",
      "event" => "updated"
    }.deep_symbolize_keys
  end

  let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id) }

  describe "#call" do
    before do
      allow(UpsertRecordJob).to receive(:perform_async)
    end

    it "enqueues upsert record job" do
      expect(UpsertRecordJob).to receive(:perform_async)
        .with("Organisation", data)
      subject
    end

    context "when the organisation is not found" do
      let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: "some-id") }

      it "does not enqueue a job" do
        expect(UpsertRecordJob).not_to receive(:perform_async)
        subject
      end
    end

    context "when it is not an update event" do
      let!(:meta) do
        {
          "model" => "Organisation",
          "event" => "destroyed"
        }.deep_symbolize_keys
      end

      it "does not enqueue a job" do
        expect(UpsertRecordJob).not_to receive(:perform_async)
        subject
      end
    end
  end
end
