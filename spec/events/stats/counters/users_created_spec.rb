describe Stats::Counters::UsersCreated do
  before do
    Redis.new.flushall
  end

  describe "counter" do
    context "when user is created" do
      it "increments counter" do
        Sidekiq::Testing.inline! do
          expect { create(:user) }.to change {
            described_class.value(scope: Department.new)
          }.from(0).to(1)
        end
      end
    end
  end
end
