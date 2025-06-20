RSpec.describe Sidekiq::Middleware::SetCurrentAgent do
  describe "#call" do
    subject { described_class.new.call("worker", job, "default") { "ok" } }

    let(:job) { { "wrapped" => "TestJob" } }

    before do
      allow(Sidekiq).to receive(:logger).and_return(Logger.new(StringIO.new))
    end

    context "when current_agent_id is present in job" do
      let(:job) { { "current_agent_id" => agent.id, "wrapped" => "TestJob" } }
      let(:agent) { create(:agent) }

      it "logs job started with agent_id" do
        allow(Sidekiq.logger).to receive(:info)
        subject
        expect(Sidekiq.logger).to have_received(:info).with("[agent_id: #{agent.id}] Job started: TestJob")
      end
    end

    context "when current_agent_id is not present in job" do
      it "logs job started without agent_id" do
        allow(Sidekiq.logger).to receive(:info)
        subject
        expect(Sidekiq.logger).to have_received(:info).with("Job started: TestJob")
      end
    end
  end
end
