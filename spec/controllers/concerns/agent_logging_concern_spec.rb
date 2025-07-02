RSpec.describe AgentLoggingConcern, type: :controller do
  controller(ApplicationController) do
    def test_action
      Rails.logger.info "Test message"
      render plain: "OK"
    end
  end

  let!(:agent) { create(:agent, id: 123) }

  before do
    routes.draw { post "test_action" => "anonymous#test_action" }
  end

  describe "#with_agent_logging" do
    context "when agent is logged in" do
      before do
        sign_in(agent)
      end

      it "logs messages with agent_id tag" do
        allow(Rails.logger).to receive(:tagged)
        post :test_action
        expect(Rails.logger).to have_received(:tagged).with("agent_id: 123")
      end
    end

    context "when no agent is logged in" do
      it "logs messages without agent_id tag" do
        allow(Rails.logger).to receive(:tagged)
        post :test_action
        expect(Rails.logger).not_to have_received(:tagged)
      end
    end
  end
end
