describe Stats::RateOfAutonomousUsers do
  before do
    Redis.new.flushall
  end

  describe "counter" do
    context "when a participation is created" do
      let(:rdv) { create(:rdv) }

      it "adds the offset in days with the invitation" do
        Sidekiq::Testing.inline! do
          expect { rdv }.to change {
            described_class.value(scope: Department.new)
          }.from(0).to(100.0)

          expect do
            rdv.participations.first.dup.update!(user: create(:user), created_by: "agent")
          end.to change {
            described_class.value(scope: Department.new)
          }.from(100.0).to(50.0)
        end
      end
    end
  end
end
