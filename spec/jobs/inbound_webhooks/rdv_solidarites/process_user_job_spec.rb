describe InboundWebhooks::RdvSolidarites::ProcessUserJob do
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

  let!(:user) do
    create(:user, rdv_solidarites_user_id: rdv_solidarites_user_id, first_name: "Jane", email: "jane@something.com")
  end

  describe "#call" do
    before do
      allow(SoftDeleteUserJob).to receive(:perform_later)
    end

    it "updates the user" do
      subject
      expect(user.reload).to have_attributes(
        first_name: "John",
        last_name: "Doe",
        phone_number: "+33624242424",
        affiliation_number: "CAUCSCUAHSC",
        email: "user@something.com",
        last_webhook_update_received_at: timestamp.to_datetime
      )
    end

    context "when the user is not found" do
      let!(:user) do
        create(:user, rdv_solidarites_user_id: 23, first_name: "Jane", email: "jane@something.com")
      end

      it "does not create the user" do
        expect { subject }.not_to change(User, :count)
      end

      it "does not update any user" do
        subject
        expect(user.reload).to have_attributes(first_name: "Jane", email: "jane@something.com")
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
        expect(SoftDeleteUserJob).to receive(:perform_later)
          .with(rdv_solidarites_user_id)
        subject
      end

      it "does not update the user" do
        subject
        expect(user.reload).to have_attributes(first_name: "Jane", email: "jane@something.com")
      end
    end
  end
end
