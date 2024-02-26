describe Stats::ComputeRateOfUsersWithRdvSeenInLessThanNDays, type: :service do
  describe "for 30 days" do
    subject { described_class.call(users: users, number_of_days: 30) }

    let(:created_at) { Time.zone.parse("17/03/2022 12:00") }
    let!(:now) { Time.zone.parse("25/04/2022 12:00") }

    let!(:users) { User.where(id: [user1, user2, user3, user4]) }

    # First user : created > 1 month ago, has a rdv_seen_delay_in_days present and the delay is less than 30 days
    # => considered as oriented in less than 30 days
    let!(:user1) { create(:user, created_at:) }
    let!(:rdv_context1) { create(:rdv_context, created_at:, user: user1) }
    let!(:rdv1) { create(:rdv, created_at:, starts_at: (created_at + 2.days), status: "seen") }
    let!(:participation1) do
      create(:participation, rdv_context: rdv_context1, user: user1,
                             rdv: rdv1, created_at:, status: "seen")
    end

    # Second user : created > 1 month ago, has a rdv_seen_delay_in_days present and the delay is more than 30 days
    # => not considered as oriented in less than 30 days
    let!(:user2) { create(:user, created_at:) }
    let!(:rdv_context2) { create(:rdv_context, created_at:, user: user2) }
    let!(:rdv2) { create(:rdv, created_at:, starts_at: (created_at + 33.days), status: "seen") }
    let!(:participation2) do
      create(:participation, rdv_context: rdv_context2, user: user2,
                             rdv: rdv2, created_at:, status: "seen")
    end

    # Third user : created > 1 month ago, has no rdv_seen_delay_in_days present
    # => not considered as oriented in less than 30 days
    let!(:user3) { create(:user, created_at:) }
    let!(:rdv_context3) { create(:rdv_context, created_at:, user: user3) }

    # Fourth user : everything okay but created less than 30 days ago
    # not taken into account in the computing
    let!(:user4) { create(:user, created_at: 20.days.ago) }
    let!(:rdv_context4) { create(:rdv_context, created_at: 20.days.ago, user: user4) }
    let!(:rdv4) { create(:rdv, created_at: 17.days.ago, starts_at: 15.days.ago, status: "seen") }
    let!(:participation4) do
      create(:participation, rdv_context: rdv_context4, user: user4,
                             rdv: rdv4, created_at: 17.days.ago, status: "seen")
    end

    before do
      travel_to(now)
    end

    describe "#call" do
      let!(:result) { subject }

      it "is a success" do
        expect(result.success?).to eq(true)
      end

      it "renders a float" do
        expect(result.value).to be_a(Float)
      end

      it "computes the percentage of users with rdv seen in less than 30 days" do
        expect(result.value).to eq(33.33333333333333)
      end
    end
  end

  describe "for 15 days" do
    subject { described_class.call(users: users, number_of_days: 15) }

    let(:created_at) { Time.zone.parse("17/03/2022 12:00") }
    let!(:now) { Time.zone.parse("10/04/2022 12:00") }

    let!(:users) { User.where(id: [user1, user2, user3, user4]) }

    # First user : created > 15 days ago, has a rdv_seen_delay_in_days present and the delay is less than 30 days
    # => considered as oriented in less than 15 days
    let!(:user1) { create(:user, created_at:) }
    let!(:rdv_context1) { create(:rdv_context, created_at:, user: user1) }
    let!(:rdv1) { create(:rdv, created_at:, starts_at: (created_at + 2.days), status: "seen") }
    let!(:participation1) do
      create(:participation, rdv_context: rdv_context1, user: user1,
                             rdv: rdv1, created_at:, status: "seen")
    end

    # Second user : created > 15 days ago, has a rdv_seen_delay_in_days present and the delay is more than 15 days
    # => not considered as oriented in less than 15 days
    let!(:user2) { create(:user, created_at:) }
    let!(:rdv_context2) { create(:rdv_context, created_at:, user: user2) }
    let!(:rdv2) { create(:rdv, created_at:, starts_at: (created_at + 16.days), status: "seen") }
    let!(:participation2) do
      create(:participation, rdv_context: rdv_context2, user: user2,
                             rdv: rdv2, created_at:, status: "seen")
    end

    # Third user : created > 15 days ago, has no rdv_seen_delay_in_days present
    # => not considered as oriented in less than 15 days
    let!(:user3) { create(:user, created_at:) }
    let!(:rdv_context3) { create(:rdv_context, created_at:, user: user3) }

    # Fourth user : everything okay but created less than 15 days ago
    # not taken into account in the computing
    let!(:user4) { create(:user, created_at: 10.days.ago) }
    let!(:rdv_context4) { create(:rdv_context, created_at: 10.days.ago, user: user4) }
    let!(:rdv4) { create(:rdv, created_at: 7.days.ago, starts_at: 3.days.ago, status: "seen") }
    let!(:participation4) do
      create(:participation, rdv_context: rdv_context4, user: user4,
                             rdv: rdv4, created_at: 7.days.ago, status: "seen")
    end

    before do
      travel_to(now)
    end

    describe "#call" do
      let!(:result) { subject }

      it "is a success" do
        expect(result.success?).to eq(true)
      end

      it "renders a float" do
        expect(result.value).to be_a(Float)
      end

      it "computes the percentage of users with rdv seen in less than 15 days" do
        expect(result.value).to eq(33.33333333333333)
      end
    end
  end
end
