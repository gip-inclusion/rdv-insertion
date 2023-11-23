describe Stats::CounterCache::NumberOfAgents do
  before do
    Redis.new.flushall
  end

  describe "counter" do
    context "when agent is created" do
      it "increments counter" do
        Sidekiq::Testing.inline! do
          expect { create(:agent) }.to change {
            described_class.value(scope: Department.new)
          }.from(0).to(1)
        end
      end
    end
  end
end
