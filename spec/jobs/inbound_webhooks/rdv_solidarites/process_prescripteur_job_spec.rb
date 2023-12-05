describe InboundWebhooks::RdvSolidarites::ProcessPrescripteurJob do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "id" => rdv_solidarites_prescripteur_id,
      "participation_id" => rdv_solidarites_participation_id,
      "email" => "linus@linux.com",
      "first_name" => "Linus",
      "last_name" => "Linux"
    }.deep_symbolize_keys
  end

  let!(:meta) do
    {
      "model" => "Prescripteur",
      "event" => "created",
      "timestamp" => "2022-05-30 14:44:22 +0200"
    }.deep_symbolize_keys
  end

  let!(:participation) { create(:participation, rdv_solidarites_participation_id:) }
  let!(:rdv_solidarites_prescripteur_id) { 123 }
  let!(:rdv_solidarites_participation_id) { 123 }

  describe "#perform" do
    it "upserts the prescripteur" do
      expect(UpsertRecordJob).to receive(:perform_async)
        .with("Prescripteur", data, {
                last_webhook_update_received_at: "2022-05-30 14:44:22 +0200",
                participation_id: participation.id
              })
      subject
    end

    context "when it is a destroyed event" do
      let!(:prescripteur) { create(:prescripteur, rdv_solidarites_prescripteur_id:, participation:) }

      let!(:meta) do
        {
          "model" => "Prescripteur",
          "event" => "destroyed",
          "timestamp" => "2022-05-30 14:44:22 +0200"
        }.deep_symbolize_keys
      end

      it "deletes the prescripteur" do
        expect(UpsertRecordJob).not_to receive(:perform_async)
        expect { subject }.to change(Prescripteur, :count).by(-1)
      end
    end
  end
end
