RSpec.describe Sidekiq::Logger::Formatters::CustomLogFormatter do
  let(:formatter) { described_class.new }
  let(:time) { Time.zone.now }
  let(:program_name) { "sidekiq" }

  describe "#call" do
    describe "agent_id logging" do
      let(:message) { "Job processing started" }
      let(:agent) { create(:agent, id: 456) }

      context "when Current.agent is present" do
        before do
          allow(Current).to receive(:agent).and_return(agent)
        end

        it "adds agent_id tag to the message" do
          formatted_message = formatter.call("INFO", time, program_name, message)

          expect(formatted_message).to include("[agent_id: 456] Job processing started")
        end

        it "does not add agent_id tag if already present" do
          message_with_agent_id = "[agent_id: 456] Job processing started"

          formatted_message = formatter.call("INFO", time, program_name, message_with_agent_id)

          expect(formatted_message).to include("[agent_id: 456] Job processing started")
          expect(formatted_message.scan("[agent_id: 456]").count).to eq(1)
        end
      end

      context "when Current.agent is nil" do
        before do
          allow(Current).to receive(:agent).and_return(nil)
        end

        it "does not add agent_id tag" do
          formatted_message = formatter.call("INFO", time, program_name, message)

          expect(formatted_message).not_to include("[agent_id:")
          expect(formatted_message).to include("Job processing started")
        end
      end
    end

    context "when logging a job with sensitive and non-sensitive arguments" do
      let(:message_with_sensitive_args) do
        {
          "context" => "Job raised exception",
          "job" => {
            "args" => [
              { "arguments" => [
                { "id" => 123, "email" => "user@example.com", "name" => "John Doe",
                  "timestamp" => "2024-20-07T12:34:56Z",
                  "password" => "supersecret", "created_at" => "2024-10-07T12:34:56Z" }
              ] }
            ]
          }
        }.to_json
      end

      it "filters sensitive data and retains non-sensitive data" do
        filtered_message = formatter.call("WARN", time, program_name, message_with_sensitive_args)

        expect(filtered_message).to include("2024-20-07T12:34:56Z")
        expect(filtered_message).to include("2024-10-07T12:34:56Z")
        expect(filtered_message).to include("123")
        expect(filtered_message).to include("[FILTERED]")

        # Ensure that sensitive data is not present
        expect(filtered_message).not_to include("user@example.com")
        expect(filtered_message).not_to include("John Doe")
        expect(filtered_message).not_to include("supersecret")
      end
    end

    context "when logging a simple non-JSON message" do
      let(:message) { "This is not JSON" }

      it "logs the message without raising an error" do
        expect { formatter.call("ERROR", time, program_name, message) }.not_to raise_error
        filtered_message = formatter.call("ERROR", time, program_name, message)
        expect(filtered_message).to include("This is not JSON")
      end
    end
  end
end
