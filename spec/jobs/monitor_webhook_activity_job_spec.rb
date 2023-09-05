describe MonitorWebhookActivityJob do
  subject do
    described_class.new.perform
  end

  describe "#perform" do
    context "when there are no models with webhook activity in the last 24 hours" do
      before do
        create(:agent, last_webhook_update_received_at: 23.hours.ago)
      end

      it "sends a message to Mattermost" do
        all_except_agent = MonitorWebhookActivityJob::MONITORED_MODELS - [Agent]
        expect(MattermostClient).to receive(:send_to_notif_channel).with(include(all_except_agent.join(", ")))

        subject
      end
    end

    context "when there are models with webhook activity in the last 24 hours" do
      before do
        MonitorWebhookActivityJob::MONITORED_MODELS.each do |model|
          create(model.name.underscore.to_sym, last_webhook_update_received_at: 23.hours.ago)
        end
      end

      it "does not send a message to Mattermost" do
        expect(MattermostClient).not_to receive(:send_to_notif_channel)
        subject
      end
    end
  end
end
