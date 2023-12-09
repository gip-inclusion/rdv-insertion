describe Rates::UsersWithRdvSeen do
  before do
    Redis.new.flushall
  end

  describe "counter" do
    context "when a participation is seen" do
      it "increments counter" do
        Sidekiq::Testing.inline! do
          user = create(:user)
          participation = create(:participation, user: user)

          expect { participation.seen! }.to change(described_class, :value).from(0).to(50.0)
        end
      end
    end

    context "when a participation is destroyed" do
      it "decrements counter when user has no more participation" do
        Sidekiq::Testing.inline! do
          user = create(:user)
          user2 = create(:user)
          participation = create(:participation, user: user)
          participation2 = create(:participation, user: user2)

          participation.seen!
          participation2.seen!

          expect(Counters::UsersWithRdvSeen.value).to eq(2)
          participation.destroy
          expect(Counters::UsersWithRdvSeen.value).to eq(1)
          participation2.destroy
          expect(Counters::UsersWithRdvSeen.value).to eq(0)
        end
      end
    end
  end
end
