describe InboundWebhooks::RdvSolidarites::ProcessOrganisationJob do
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
      "event" => "updated",
      "timestamp" => "2022-05-30 14:44:22 +0200"
    }.deep_symbolize_keys
  end

  let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id) }

  describe "#call" do
    before do
      allow(UpsertRecordJob).to receive(:perform_async)
    end

    it "enqueues upsert record job" do
      expect(UpsertRecordJob).to receive(:perform_async)
        .with("Organisation", data, { last_webhook_update_received_at: "2022-05-30 14:44:22 +0200" })
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

    context "when verticale attribute is invalid" do
      let!(:data) do
        {
          "id" => rdv_solidarites_organisation_id,
          "name" => "CD 28",
          "email" => "contact@cd28.fr",
          "phone_number" => "+33624242424",
          "verticale" => "rdv_solidarites"
        }.deep_symbolize_keys
      end

      it "send a sentry message" do
        expect(Sentry).to receive(:capture_message).with(
          "Verticale attribute is not valid for rdv_solidarites_organisation_id : #{rdv_solidarites_organisation_id}"
        )
        subject
      end
    end
  end
end
