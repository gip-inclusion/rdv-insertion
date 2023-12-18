describe Counters::UsersWithRdvTaken do
  before do
    Redis.new.flushall
  end

  describe "counter" do
    context "when a participation is created and destroyed" do
      it "increments and decrements counter" do
        Sidekiq::Testing.inline! do
          expect(described_class.value).to eq(0)
          user = create(:user)
          participation1 = create(:participation, user:)
          participation2 = create(:participation, user:)
          participation3 = create(:participation, user:)
          base_value = described_class.value

          participation1.destroy
          expect(described_class.value).to eq(base_value)

          participation2.destroy
          expect(described_class.value).to eq(base_value)

          # Only now we should see the counter decrease
          participation3.destroy
          expect(described_class.value).to eq(base_value - 1)
        end
      end
    end
  end
end
