describe InboundWebhooks::Brevo::AssignMailDeliveryStatusAndDate do
  subject { described_class.call(webhook_params: webhook_params, record: record) }

  let(:webhook_params) { { email: "Test@example.com", event: "delivered", date: "2023-06-07T12:34:56Z" } }
  let!(:user) { create(:user, email: "test@example.com", invitations: []) }
  let!(:participation) { create(:participation, user: user) }
  let(:notification) { create(:notification, participation: participation) }
  let!(:invitation) { build(:invitation, user: user) }

  %w[invitation notification].each do |record_type|
    context "for an #{record_type}" do
      let(:record) { send(record_type) }

      context "when the #{record_type} had a failed delivery status and the delivery status is now delivered" do
        it "update the #{record_type} with delivered status" do
          record.update(delivery_status: "soft_bounce",
                        last_brevo_webhook_received_at: Time.zone.parse("2023-06-07T12:00:00Z"))
          subject
          record.reload
          expect(record.delivery_status).to eq("delivered")
          expect(record.last_brevo_webhook_received_at).to eq(Time.zone.parse("2023-06-07T12:34:56Z"))
        end
      end

      it "updates the #{record_type} with the correct delivery status and date" do
        subject
        record.reload
        expect(record.delivery_status).to eq("delivered")
        expect(record.last_brevo_webhook_received_at).to eq(Time.zone.parse("2023-06-07T12:34:56Z"))
      end

      context "when the delivery status is not in enum" do
        let(:webhook_params) { { email: "test@example.com", event: "opened", date: "2023-06-07T12:34:56Z" } }

        it "doesnt update the #{record_type} delivery_status but update last_brevo_webhook_received_at" do
          subject
          record.reload
          expect(record.delivery_status).to eq(nil)
          expect(record.last_brevo_webhook_received_at).to eq(Time.zone.parse("2023-06-07T12:34:56Z"))
        end
      end

      context "when the record is already delivered" do
        let(:webhook_params) { { email: "test@example.com", event: "error", date: "2023-06-07T12:34:56Z" } }

        it "does not update the #{record_type}" do
          record.update(delivery_status: "delivered",
                        last_brevo_webhook_received_at: Time.zone.parse("2023-06-07T12:00:00Z"))
          subject
          record.reload
          expect(record.delivery_status).to eq("delivered")
          expect(record.last_brevo_webhook_received_at).to eq(Time.zone.parse("2023-06-07T12:00:00Z"))
        end
      end

      context "when the update is old" do
        let!(:old_date) { "2022-06-07T12:34:56Z" }
        let!(:webhook_params) { { email: "test@example.com", event: "error", date: old_date } }

        it "does not update the #{record_type}" do
          record.update(last_brevo_webhook_received_at: Time.zone.parse("2023-06-08T12:34:56Z"),
                        delivery_status: "blocked")
          subject
          record.reload
          expect(record.delivery_status).to eq("blocked")
          expect(record.delivered_at).not_to eq(old_date)
        end
      end
    end
  end
end
