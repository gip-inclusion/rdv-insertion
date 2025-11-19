describe MonitorWebhookActivityJob do
  subject do
    described_class.new.perform
  end

  describe "#perform" do
    context "some models without webhook in the acceptable delay" do
      before do
        create(:agent, last_webhook_update_received_at: 10.minutes.ago)
      end

      it "sends a message to slack" do
        all_except_agent = MonitorWebhookActivityJob::MONITORS
                           .reject { |m| m[:model] == Agent }
                           .pluck(:model)
                           .map(&:name)
                           .join(", ")

        expect(SlackClient).to receive(:send_to_notif_channel).with(include(all_except_agent))

        subject
      end
    end

    context "all models have webhook activity in the acceptable delay" do
      before do
        MonitorWebhookActivityJob::MONITORS.each do |monitor|
          create(monitor[:model].name.underscore.to_sym,
                 last_webhook_update_received_at: monitor[:acceptable_delay].ago + 1.minute)
        end
      end

      it "does not send a message to slack" do
        expect(SlackClient).not_to receive(:send_to_notif_channel)
        subject
      end
    end
  end
end
