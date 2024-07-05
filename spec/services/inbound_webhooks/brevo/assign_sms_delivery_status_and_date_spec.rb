describe InboundWebhooks::Brevo::AssignSmsDeliveryStatusAndDate do
  subject { described_class.call(webhook_params: webhook_params, record: record) }

  let(:webhook_params) { { to: "0601010101", msg_status: "delivered", date: "2023-06-07T12:34:56Z" } }
  let(:user) { create(:user, phone_number: "0601010101") }
  let(:invitation) { create(:invitation, user: user) }
  let!(:participation) { create(:participation, user: user) }
  let(:notification) { create(:notification, participation: participation) }

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

      context "when the phone number does not match" do
        let(:webhook_params) { { to: "0987654321", msg_status: "delivered", date: "2023-06-07T12:34:56Z" } }

        it "does not update the #{record_type}" do
          expect(Sentry).to receive(:capture_message).with(
            "#{record_type.capitalize} mobile phone and webhook mobile phone does not match", any_args
          )
          subject
          expect(record.delivery_status).to be_nil
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
        let(:webhook_params) { { to: "0601010101", msg_status: "opened", date: "2023-06-07T12:34:56Z" } }

        it "doesnt update the #{record_type} delivery_status but update last_brevo_webhook_received_at" do
          subject
          record.reload
          expect(record.delivery_status).to eq(nil)
          expect(record.last_brevo_webhook_received_at).to eq(Time.zone.parse("2023-06-07T12:34:56Z"))
        end
      end
    end
  end
end