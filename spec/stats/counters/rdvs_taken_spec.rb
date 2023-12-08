describe Counters::RdvsTaken do
  before do
    Redis.new.flushall
  end

  describe "counter" do
    context "when a participation is created" do
      it "increments counter" do
        Sidekiq::Testing.inline! do
          expect do
            # Factories creates a participation when creating a rdv
            create(:rdv)
          end.to change(described_class, :value).from(0).to(1)
        end
      end
    end
  end
end
