describe MonitorInboundEmailsActivityJob do
  subject do
    described_class.new.perform
  end

  describe "#perform" do
    context "when the last inbound email was received less than 7 days ago" do
      before do
        RedisConnection.with_redis do |redis|
          redis.set("last_inbound_email_received_at", 6.days.ago.to_i)
        end
      end

      it "does not send a message to Mattermost" do
        expect(MattermostClient).not_to receive(:send_to_private_channel)
        subject
      end
    end

    context "when the last inbound email was received more than 7 days ago" do
      let(:last_inbound_email_received_at) { 8.days.ago }

      before do
        RedisConnection.with_redis do |redis|
          redis.set("last_inbound_email_received_at", last_inbound_email_received_at.to_i)
        end
      end

      it "sends a message to Mattermost" do
        expect(MattermostClient).to receive(:send_to_private_channel).with(
          "⚠️ Les emails des usagers n'ont pas été transérés depuis plus de 7 jours!\n" \
          "Dernier email reçu le #{last_inbound_email_received_at.strftime("%d/%m/%Y %H:%M")}"
        )
        subject
      end
    end
  end
end