describe RdvSolidaritesWebhooks::ProcessUserJob do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "id" => rdv_solidarites_user_id,
      "first_name" => "John",
      "last_name" => "Doe",
      "phone_number" => "+33624242424",
      "affiliation_number" => "CAUCSCUAHSC",
      "email" => "user@something.com"
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_user_id) { 22 }

  let!(:timestamp) { "2021-05-30 14:44:22 +0200" }
  let!(:meta) do
    {
      "model" => "User",
      "event" => "updated",
      "timestamp" => timestamp
    }.deep_symbolize_keys
  end

  let!(:user) { create(:user, rdv_solidarites_user_id: rdv_solidarites_user_id) }

  describe "#call" do
    before do
      allow(UpsertRecordJob).to receive(:perform_async)
      allow(SoftDeleteUserJob).to receive(:perform_async)
    end

    it "enqueues upsert record job" do
      expect(UpsertRecordJob).to receive(:perform_async)
        .with("User", data, { last_webhook_update_received_at: timestamp })
      subject
    end

    context "when the affiliation number received is nil" do
      before { data.merge!(affiliation_number: nil) }

      it "enqueues an upsert record job without affiliation_number" do
        filtered_data = data.except(:affiliation_number)
        expect(UpsertRecordJob).to receive(:perform_async)
          .with("User", filtered_data, { last_webhook_update_received_at: timestamp })
        subject
      end
    end

    context "when the email received is nil" do
      before { data.merge!(email: nil) }

      it "enqueues an upsert record job without the email" do
        filtered_data = data.except(:email)
        expect(UpsertRecordJob).to receive(:perform_async)
          .with("User", filtered_data, { last_webhook_update_received_at: timestamp })
        subject
      end
    end

    context "when the user is not found" do
      let!(:user) { create(:user, rdv_solidarites_user_id: "some-id") }

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

      it "enqueues a delete user job" do
        expect(SoftDeleteUserJob).to receive(:perform_async)
          .with(rdv_solidarites_user_id)
        subject
      end

      it "does not enque an upsert record job" do
        expect(UpsertRecordJob).not_to receive(:perform_async)
        subject
      end
    end

    context "when webohook reason is rgpd" do
      let!(:meta) do
        {
          "model" => "User",
          "event" => "destroyed",
          "webhook_reason" => "rgpd"
        }.deep_symbolize_keys
      end

      it "enqueues a nullify job" do
        expect(NullifyRdvSolidaritesIdJob).to receive(:perform_async)
          .with("User", user.id)
        subject
      end

      it "does not enqueue a delete user job" do
        expect(SoftDeleteUserJob).not_to receive(:perform_async)
        subject
      end

      it "does not enque an upsert record job" do
        expect(UpsertRecordJob).not_to receive(:perform_async)
        subject
      end
    end
  end
end
