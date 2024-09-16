describe InboundWebhooks::RdvSolidarites::ProcessLieuJob do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "id" => rdv_solidarites_lieu_id,
      "name" => "Mairie de Valence",
      "address" => "20 avenue de la République 26000 Valence",
      "phone_number" => "01 01 01 01 01",
      "organisation_id" => rdv_solidarites_organisation_id
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_organisation_id) { 222 }
  let!(:rdv_solidarites_lieu_id) { 455 }

  let!(:meta) do
    {
      "model" => "Lieu",
      "event" => "updated",
      "timestamp" => "2022-05-30 14:44:22 +0200"
    }.deep_symbolize_keys
  end

  let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id) }

  describe "#call" do
    before do
      allow(UpsertRecordJob).to receive(:perform_later)
    end

    it "enqueues upsert record job" do
      expect(UpsertRecordJob).to receive(:perform_later)
        .with(
          "Lieu", data,
          { organisation_id: organisation.id, last_webhook_update_received_at: "2022-05-30 14:44:22 +0200" }
        )
      subject
    end

    context "when the organisation is not found" do
      let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: "some-id") }

      it "does not enqueue a job" do
        expect(UpsertRecordJob).not_to receive(:perform_later)
        subject
      end
    end

    context "when it is the destroy event" do
      let!(:lieu) { create(:lieu, rdv_solidarites_lieu_id: rdv_solidarites_lieu_id) }

      let!(:meta) do
        {
          "model" => "Lieu",
          "event" => "destroyed",
          "timestamp" => "2022-05-30 14:44:22 +0200"
        }.deep_symbolize_keys
      end

      it "deletes the lieu" do
        expect(UpsertRecordJob).not_to receive(:perform_later)
        expect { subject }.to change(Lieu, :count).by(-1)
      end
    end
  end
end
