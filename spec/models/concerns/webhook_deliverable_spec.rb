describe WebhookDeliverable, type: :concern do
  let!(:organisation) { create(:organisation, organisation_type:) }
  let!(:organisation_type) { "conseil_departemental" }
  let!(:webhook_endpoint) do
    create(
      :webhook_endpoint,
      organisation:,
      subscriptions: %w[rdv invitation]
    )
  end
  let!(:now) { Time.zone.parse("21/01/2023 23:42:11") }

  before do
    travel_to now
    allow(OutgoingWebhooks::SendWebhookJob).to receive(:perform_later)
  end

  describe "#send_webhook" do
    context "when the webhook endpoint is triggered by the model changes" do
      let!(:webhook_payload) do
        { meta:, data: rdv.as_json(organisation_type:) }
      end
      let!(:meta) do
        { event:, timestamp: now, model: "Rdv" }
      end

      context "on creation" do
        let!(:rdv) { build(:rdv, organisation: organisation) }
        let!(:event) { :created }

        it "notifies the creation" do
          expect(OutgoingWebhooks::SendWebhookJob).to receive(:perform_later)
          # we don't put the arguments because it is difficult since the rdv is not created yet
          rdv.save
        end
      end

      context "on update" do
        let!(:rdv) { create(:rdv, organisation: organisation) }
        let!(:event) { :updated }

        it "notifies on update" do
          expect(OutgoingWebhooks::SendWebhookJob).to receive(:perform_later)
            .with(webhook_endpoint.id, webhook_payload)
          rdv.save
        end
      end

      context "on deletion" do
        let!(:rdv) { create(:rdv, organisation: organisation) }
        let!(:event) { :destroyed }

        it "notifies on deletion" do
          expect(OutgoingWebhooks::SendWebhookJob).to receive(:perform_later)
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
          expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_later)
          rdv.save
        end
      end

      context "on update" do
        let!(:rdv) { create(:rdv, organisation: organisation) }

        it "does not send webhook" do
          rdv.should_send_webhook = false
          expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_later)
          rdv.save
        end
      end

      context "on deletion" do
        let!(:rdv) { create(:rdv, organisation: organisation) }

        it "does not send webhook on deletion" do
          rdv.should_send_webhook = false
          expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_later)
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
          expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_later)
          rdv.save
        end
      end

      context "on update" do
        let!(:rdv) { create(:rdv, organisation: organisation) }

        it "does not send webhook" do
          expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_later)
          rdv.save
        end
      end

      context "on deletion" do
        let!(:rdv) { create(:rdv, organisation: organisation) }

        it "does not send webhook on deletion" do
          expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_later)
          rdv.destroy
        end
      end
    end

    context "payload changes depending on organisations" do
      let!(:rdv) { create(:rdv, organisation: organisation, participations: [create(:participation, user:)]) }
      let!(:user) { create(:user, nir:, department_internal_id:) }
      let!(:nir) { generate_random_nir }
      let!(:department_internal_id) { SecureRandom.uuid }

      let!(:webhook_payload) do
        { meta:, data: rdv.as_json(organisation_type:) }
      end
      let!(:meta) do
        { event: :updated, timestamp: now, model: "Rdv" }
      end

      context "when conseil departemental" do
        it "sends the nir and department id" do
          expect(webhook_payload.to_json).to include(nir)
          expect(webhook_payload.to_json).to include(department_internal_id)
          expect(OutgoingWebhooks::SendWebhookJob).to receive(:perform_later)
            .with(webhook_endpoint.id, webhook_payload)
          rdv.save
        end
      end

      context "when siae" do
        let!(:organisation_type) { "siae" }

        it "does not send the nir or the department internal id" do
          expect(webhook_payload.to_json).not_to include(nir)
          expect(webhook_payload.to_json).not_to include(department_internal_id)
          expect(OutgoingWebhooks::SendWebhookJob).to receive(:perform_later)
            .with(webhook_endpoint.id, webhook_payload)
          rdv.save
        end
      end
    end

    context "for record deletion" do
      let!(:rdv) { create(:rdv, organisation: organisation) }

      context "when the record deletion fails" do
        before do
          allow(rdv).to receive(:destroy).and_return(false)
        end

        it "does not send the webhook" do
          expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_later)
          rdv.destroy
        end
      end

      context "when the record deletion succeeds" do
        it "sends the webhook" do
          expect(OutgoingWebhooks::SendWebhookJob).to receive(:perform_later)
          rdv.destroy
        end
      end

      context "when the record deletion raises an error" do
        before do
          allow(rdv).to receive(:destroy).and_raise(StandardError)
        end

        it "does not send the webhook" do
          expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_later)
          expect { rdv.destroy }.to raise_error(StandardError)
        end
      end
    end
  end
end
