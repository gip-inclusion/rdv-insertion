RSpec.describe "BrevoMailWebhooks" do
  include_context "with ip whitelist"

  let(:webhook_params) do
    {
      email: "test@example.com",
      event: "delivered",
      date: "2023-06-07T12:34:56Z",
      :"X-Mailin-custom" => "{\"record_identifier\": \"#{record_identifier}\"}"
    }
  end
  let!(:user) { create(:user, email: "test@example.com", invitations: []) }

  before do
    allow(InboundWebhooks::Brevo::ProcessMailDeliveryStatusJob).to receive(:perform_later) do |*args|
      InboundWebhooks::Brevo::ProcessMailDeliveryStatusJob.new.perform(*args)
    end
    allow(Sentry).to receive(:capture_message)
  end

  context "for an invitation" do
    let!(:invitation) { create(:invitation, user: user) }
    let(:record_identifier) { invitation.record_identifier }

    it "processes the webhook and updates the invitation" do
      post "/brevo/mail_webhooks", params: webhook_params, as: :json
      expect(response).to be_successful

      invitation.reload
      expect(invitation.delivery_status).to eq("delivered")
      expect(invitation.last_brevo_webhook_received_at).to eq(Time.zone.parse("2023-06-07T12:34:56Z"))
    end

    context "with an event not in enum" do
      let(:unprocessed_event_webhook_params) do
        {
          email: "test@example.com",
          event: "request",
          date: "2023-06-07T12:34:56Z",
          :"X-Mailin-custom" => "{\"record_identifier\": \"#{invitation.record_identifier}\"}"
        }
      end

      it "does not update the invitation but save last_brevo_webhook_received_at date" do
        post "/brevo/mail_webhooks", params: unprocessed_event_webhook_params, as: :json
        expect(response).to be_successful

        invitation.reload
        expect(invitation.delivery_status).to be_nil
        expect(invitation.last_brevo_webhook_received_at).to eq(Time.zone.parse("2023-06-07T12:34:56Z"))
      end
    end

    context "when invitation is not found" do
      let(:invalid_webhook_params) do
        {
          email: "test@example.com",
          event: "delivered",
          date: "2023-06-07T12:34:56Z",
          :"X-Mailin-custom" => '{"record_identifier": "invitation_9999"}'
        }
      end

      it "captures an error for missing invitation" do
        post "/brevo/mail_webhooks", params: invalid_webhook_params, as: :json
        expect(response).to be_successful

        expect(Sentry).to have_received(:capture_message).with("Invitation not found", any_args)
      end
    end
  end

  context "for a notification" do
    let!(:participation) { create(:participation, user: user) }
    let!(:notification) { create(:notification, participation: participation) }
    let(:record_identifier) { notification.record_identifier }

    it "processes the webhook and updates the notification" do
      post "/brevo/mail_webhooks", params: webhook_params, as: :json
      expect(response).to be_successful

      notification.reload
      expect(notification.delivery_status).to eq("delivered")
      expect(notification.last_brevo_webhook_received_at).to eq(Time.zone.parse("2023-06-07T12:34:56Z"))
    end

    context "when notification is not found" do
      let(:invalid_webhook_params) do
        {
          email: "test@example.com",
          event: "delivered",
          date: "2023-06-07T12:34:56Z",
          :"X-Mailin-custom" => '{"record_identifier": "notification_9999"}'
        }
      end

      it "captures an error for missing notification" do
        post "/brevo/mail_webhooks", params: invalid_webhook_params, as: :json
        expect(response).to be_successful

        expect(Sentry).to have_received(:capture_message).with("Notification not found", any_args)
      end
    end
  end
end
