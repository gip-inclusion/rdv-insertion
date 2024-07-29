describe WebhookDeliverable, type: :concern do
  let!(:organisation) { create(:organisation) }
  let!(:webhook_endpoint) do
    create(
      :webhook_endpoint,
      organisation:,
      subscriptions: %w[rdv invitation]
    )
  end
  let!(:now) { Time.zone.parse("21/01/2023 23:42:11") }
  let!(:data) do
    {
      id: 294,
      address: "20 avenue de Ségur 75007 Paris",
      starts_at: Time.zone.parse("21/01/2023 10:00:00")
    }
  end

  before do
    travel_to now
    allow_any_instance_of(Rdv).to receive(:as_json).and_return(data)
    allow(OutgoingWebhooks::SendWebhookJob).to receive(:perform_async)
  end

  describe "#send_webhook" do
    context "when the webhook endpoint is triggered by the model changes" do
      let!(:webhook_payload) do
        { meta:, data: rdv.as_json }
      end
      let!(:meta) do
        { event:, timestamp: now, model: "Rdv" }
      end

      context "on creation" do
        let!(:rdv) { build(:rdv, organisation: organisation) }
        let!(:event) { :created }

        it "notifies the creation" do
          expect(OutgoingWebhooks::SendWebhookJob).to receive(:perform_async)
            .with(webhook_endpoint.id, webhook_payload)
          rdv.save
        end
      end

      context "on update" do
        let!(:rdv) { create(:rdv, organisation: organisation) }
        let!(:event) { :updated }

        it "notifies on update" do
          expect(OutgoingWebhooks::SendWebhookJob).to receive(:perform_async)
            .with(webhook_endpoint.id, webhook_payload)
          rdv.save
        end
      end

      context "on deletion" do
        let!(:rdv) { create(:rdv, organisation: organisation) }
        let!(:event) { :destroyed }

        it "notifies on deletion" do
          expect(OutgoingWebhooks::SendWebhookJob).to receive(:perform_async)
            .with(webhook_endpoint.id, webhook_payload)
          rdv.destroy
        end
      end
    end

    context "when the webhook callbacks are disabled explicitly" do
      context "on creation" do
        let!(:rdv) { build(:rdv, organisation: organisation) }

        it "does not send webhook" do
          rdv.should_send_webhook = false
          expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_async)
          rdv.save
        end
      end

      context "on update" do
        let!(:rdv) { create(:rdv, organisation: organisation) }

        it "does not send webhook" do
          rdv.should_send_webhook = false
          expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_async)
          rdv.save
        end
      end

      context "on deletion" do
        let!(:rdv) { create(:rdv, organisation: organisation) }

        it "does not send webhook on deletion" do
          rdv.should_send_webhook = false
          expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_async)
          rdv.destroy
        end
      end
    end

    context "when the webhook endpoint is not triggered by the changes" do
      let!(:webhook_endpoint) do
        create(
          :webhook_endpoint,
          organisation:,
          subscriptions: %w[invitation]
        )
      end

      context "on creation" do
        let!(:rdv) { build(:rdv, organisation: organisation) }

        it "does not send webhook" do
          expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_async)
          rdv.save
        end
      end

      context "on update" do
        let!(:rdv) { create(:rdv, organisation: organisation) }

        it "does not send webhook" do
          expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_async)
          rdv.save
        end
      end

      context "on deletion" do
        let!(:rdv) { create(:rdv, organisation: organisation) }

        it "does not send webhook on deletion" do
          expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_async)
          rdv.destroy
        end
      end
    end
  end
end
