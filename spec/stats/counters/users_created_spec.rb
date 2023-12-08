describe Counters::UsersCreated do
  before do
    Redis.new.flushall
  end

  describe "counter" do
    context "when user is created" do
      it "increments counter" do
        Sidekiq::Testing.inline! do
          expect(described_class.value).to eq(0)
          user = create(:user)
          expect(described_class.value).to eq(1)
          user.destroy!
          expect(described_class.value).to eq(0)
        end
      end
    end
  end
end
