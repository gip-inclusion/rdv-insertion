describe RdvSolidaritesWebhooks::ProcessMotifJob do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "id" => rdv_solidarites_organisation_id,
      "name" => "RDV d'orientation sur site",
      "category" => "rsa_orientation",
      "service_id" => 444,
      "organisation_id" => rdv_solidarites_organisation_id
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_organisation_id) { 222 }
  let!(:rdv_solidarites_motif_id) { 455 }

  let!(:meta) do
    {
      "model" => "Motif",
      "event" => "updated",
      "timestamp" => "2022-05-30 14:44:22 +0200"
    }.deep_symbolize_keys
  end

  let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id) }

  describe "#call" do
    before do
      allow(UpsertRecordJob).to receive(:perform_async)
    end

    let!(:motif_attributes) { data.merge(rdv_solidarites_service_id: 444) }

    it "enqueues upsert record job" do
      expect(UpsertRecordJob).to receive(:perform_async)
        .with(
          "Motif", motif_attributes,
          { organisation_id: organisation.id, last_webhook_update_received_at: "2022-05-30 14:44:22 +0200" }
        )
      subject
    end

    context "when the organisation is not found" do
      let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: "some-id") }

      it "does not enqueue a job" do
        expect(UpsertRecordJob).not_to receive(:perform_async)
        subject
      end
    end
  end
end
