describe Counters::NumberOfAgents do
  before do
    Redis.new.flushall
  end

  describe "counter" do
    context "when agent is created or update" do
      it "increments counter" do
        Sidekiq::Testing.inline! do
          create(:agent, has_logged_in: true)
          expect(described_class.value).to eq(1)

          other_agent = create(:agent, has_logged_in: false)
          expect(described_class.value).to eq(1)

          other_agent.update!(has_logged_in: true)
          expect(described_class.value).to eq(2)
        end
      end
    end
  end
end
