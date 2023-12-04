describe Stats::Counters::RateOfUsersWithRdvSeenInLessThanThirtyDays do
  before do
    Redis.new.flushall
  end

  describe "counter" do
    context "when a participation is seen" do
      context "when the user has been created less than 30 days ago" do
        it "increments counter" do
          Sidekiq::Testing.inline! do
            user = create(:user, created_at: 10.days.ago)
            participation = create(:participation, user: user)

            expect { participation.seen! }.to change {
              described_class.value(scope: Department.new)
            }.from(0).to(50.0)
          end
        end
      end

      context "when the user has been created more than 30 days ago" do
        it "doesn't increment counter" do
          Sidekiq::Testing.inline! do
            user = create(:user, created_at: 2.months.ago)
            participation = create(:participation, user: user)

            expect { participation.seen! }.not_to change {
              described_class.value(scope: Department.new)
            }.from(0)
          end
        end
      end
    end
  end
end
