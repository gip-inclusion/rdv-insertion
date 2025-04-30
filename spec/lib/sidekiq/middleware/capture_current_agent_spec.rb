require "rails_helper"

RSpec.describe Sidekiq::Middleware::CaptureCurrentAgent do
  describe "#call" do
    subject { described_class.new.call(Object, job, queue, "redis_pool") { "ok" } }

    let(:job) { { "args" => [{ "job_class" => "SomeJobClass" }] } }
    let(:queue) { "default" }
    let(:redis_pool) { instance_double("redis_pool") }

    context "when Current.agent is set" do
      let(:agent) do
        create(:agent, id: 42, first_name: "Agent", last_name: "Smith", email: "agent@example.com",
                       rdv_solidarites_agent_id: 123)
      end

      before do
        allow(Current).to receive(:agent).and_return(agent)
      end

      it "stores the current agent id in the job payload" do
        subject
        expect(job["current_agent_id"]).to eq(42)
      end

      it "sets whodunnit with agent name when PaperTrail.request.whodunnit is nil" do
        allow(PaperTrail.request).to receive(:whodunnit).and_return(nil)
        subject
        expect(job["whodunnit"]).to eq(
          "[Agent via Sidekiq] Agent SMITH (agent@example.com) - ID RDV-S: 123 - job: SomeJobClass"
        )
      end

      it "formats existing whodunnit when PaperTrail.request.whodunnit is present" do
        allow(PaperTrail.request).to receive(:whodunnit).and_return("[Agent] Agent Smith")
        subject
        expect(job["whodunnit"]).to eq("[Sidekiq] [Agent] Agent Smith - job: SomeJobClass")
      end

      it "doesn't modify whodunnit if it already starts with [Sidekiq]" do
        sidekiq_whodunnit = "[Sidekiq] [Agent] Agent Smith - job: SomeJob"
        allow(PaperTrail.request).to receive(:whodunnit).and_return(sidekiq_whodunnit)
        subject
        expect(job["whodunnit"]).to eq(sidekiq_whodunnit)
      end
    end

    context "when Current.agent is nil" do
      before do
        allow(Current).to receive(:agent).and_return(nil)
      end

      it "doesn't set current_agent_id in the job payload" do
        subject
        expect(job["current_agent_id"]).to be_nil
      end

      it "sets whodunnit for sidekiq without agent" do
        allow(PaperTrail.request).to receive(:whodunnit).and_return(nil)
        subject
        expect(job["whodunnit"]).to eq("[Sidekiq sans agent] - job: SomeJobClass")
      end
    end

    context "when current_agent_id and whodunnit are already set (e.g. in a retry)" do
      let(:job) { { "current_agent_id" => 84, "whodunnit" => "[Sidekiq] Existing - job: ExistingClass" } }

      it "doesn't overwrite existing values" do
        subject
        expect(job["current_agent_id"]).to eq(84)
        expect(job["whodunnit"]).to eq("[Sidekiq] Existing - job: ExistingClass")
      end
    end
  end
end
