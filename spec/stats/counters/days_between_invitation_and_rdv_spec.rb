describe Counters::DaysBetweenInvitationAndRdv do
  before do
    Redis.new.flushall
  end

  describe "counter" do
    context "when a participation is created" do
      it "adds the offset in days with the invitation" do
        Sidekiq::Testing.inline! do
          rdv_context = create(:rdv_context)
          rdv_context.invitations << create(:invitation, user: rdv_context.user, sent_at: 10.days.ago)
          rdv = create(:rdv)

          expect do
            rdv_context.participations.create!(user: rdv_context.user, rdv:,
                                               created_by: "agent")
          end.to change(described_class, :value).from(0).to(10.0)

          other_rdv_context = create(:rdv_context)
          other_rdv_context.invitations << create(:invitation, user: other_rdv_context.user, sent_at: 5.days.ago)
          rdv = create(:rdv)

          expect do
            other_rdv_context.participations.create!(user: other_rdv_context.user, rdv:, created_by: "agent")
          end.to change(described_class, :value).from(10.0).to(7.5)
          expect(
            described_class.values_grouped_by_month[Time.zone.now.strftime("%m/%Y")]
          ).to eq(7.5)
        end
      end
    end
  end
end
