describe InboundWebhooks::RdvSolidarites::ProcessMotifJob do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "id" => rdv_solidarites_motif_id,
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
      allow(UpsertRecordJob).to receive(:perform_later)
    end

    let!(:motif_attributes) { data.merge(rdv_solidarites_service_id: 444) }

    it "enqueues upsert record job" do
      expect(UpsertRecordJob).to receive(:perform_later)
        .with(
          "Motif", motif_attributes,
          { organisation_id: organisation.id, motif_category_id: nil, last_webhook_update_received_at: "2022-05-30 14:44:22 +0200" }
        )
      subject
    end

    context "when there is a motif category attached" do
      let!(:motif_category) { create(:motif_category, short_name: "rsa_orientation") }
      let!(:data) do
        {
          "id" => rdv_solidarites_organisation_id,
          "name" => "RDV d'orientation sur site",
          "category" => "rsa_orientation",
          "service_id" => 444,
          "organisation_id" => rdv_solidarites_organisation_id,
          "motif_category" => { "short_name" => "rsa_orientation" }
        }.deep_symbolize_keys
      end

      it "enqueues upsert record job with the motif category" do
        expect(UpsertRecordJob).to receive(:perform_later)
          .with(
            "Motif", motif_attributes,
            {
              organisation_id: organisation.id,
              last_webhook_update_received_at: "2022-05-30 14:44:22 +0200",
              motif_category_id: motif_category.id
            }
          )
        subject
      end
    end

    context "when it is the destroy event" do
      let!(:motif) { create(:motif, rdv_solidarites_motif_id: rdv_solidarites_motif_id) }

      let!(:meta) do
        {
          "model" => "Motif",
          "event" => "destroyed",
          "timestamp" => "2022-05-30 14:44:22 +0200"
        }.deep_symbolize_keys
      end

      it "deletes the lieu" do
        expect(UpsertRecordJob).not_to receive(:perform_later)
        expect { subject }.to change(Motif, :count).by(-1)
      end
    end

    context "when the organisation is not found" do
      let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: "some-id") }

      it "does not enqueue a job" do
        expect(UpsertRecordJob).not_to receive(:perform_later)
        subject
      end
    end
  end
end
