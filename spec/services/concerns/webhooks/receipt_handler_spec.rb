describe Webhooks::ReceiptHandler do
  let(:dummy_class) { Class.new { include Webhooks::ReceiptHandler } }
  let(:instance) { dummy_class.new }
  let(:webhook_endpoint) { create(:webhook_endpoint) }

  describe "#with_webhook_receipt" do
    let(:resource_model) { "TestModel" }
    let(:resource_id) { 1 }
    let(:timestamp) { Time.current }
    let(:webhook_endpoint_id) { webhook_endpoint.id }

    context "when no previous receipt exists" do
      it "creates a new webhook receipt" do
        expect do
          instance.with_webhook_receipt(
            resource_model: resource_model,
            resource_id: resource_id,
            timestamp: timestamp,
            webhook_endpoint_id: webhook_endpoint_id
          ) { true }
        end.to change(WebhookReceipt, :count).by(1)
      end
    end

    context "when a previous receipt exists with an older timestamp" do
      before do
        create(:webhook_receipt,
               resource_model: resource_model,
               resource_id: resource_id,
               timestamp: 1.hour.ago,
               webhook_endpoint_id: webhook_endpoint_id)
      end

      it "creates a new webhook receipt" do
        expect do
          instance.with_webhook_receipt(
            resource_model: resource_model,
            resource_id: resource_id,
            timestamp: timestamp,
            webhook_endpoint_id: webhook_endpoint_id
          ) { true }
        end.to change(WebhookReceipt, :count).by(1)
      end
    end

    context "when a previous receipt exists with a newer timestamp" do
      before do
        create(:webhook_receipt,
               resource_model: resource_model,
               resource_id: resource_id,
               timestamp: 1.hour.from_now,
               webhook_endpoint_id: webhook_endpoint_id)
      end

      it "does not create a new webhook receipt" do
        expect do
          instance.with_webhook_receipt(
            resource_model: resource_model,
            resource_id: resource_id,
            timestamp: timestamp,
            webhook_endpoint_id: webhook_endpoint_id
          ) { true }
        end.not_to change(WebhookReceipt, :count)
      end
    end
  end
end
