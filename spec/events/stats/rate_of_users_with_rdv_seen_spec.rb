describe Stats::RateOfUsersWithRdvSeen do
  before do
    Redis.new.flushall
  end

  describe "counter" do
    context "when a participation is seen" do
      it "increments counter" do
        Sidekiq::Testing.inline! do
          user = create(:user)
          participation = create(:participation, user: user)

          expect { participation.seen! }.to change {
            described_class.value(scope: Department.new)
          }.from(0).to(50.0)
        end
      end
    end
  end
end
