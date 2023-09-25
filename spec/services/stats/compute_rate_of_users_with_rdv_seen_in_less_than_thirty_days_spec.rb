describe Stats::ComputeRateOfUsersWithRdvSeenInLessThanThirtyDays, type: :service do
  subject { described_class.call(users: users) }

  let(:date) { Time.zone.parse("17/03/2022 12:00") }

  let!(:users) { User.where(id: [user1, user2, user3, user4]) }

  # First user : created 1 month ago, has a rdv_seen_delay_in_days present and the delay is less than 30 days
  # => considered as oriented in less than 30 days
  let!(:user1) { create(:user, created_at: date) }
  let!(:rdv_context1) { create(:rdv_context, created_at: date, user: user1) }
  let!(:rdv1) { create(:rdv, created_at: date, starts_at: (date + 2.days), status: "seen") }
  let!(:participation1) do
    create(:participation, rdv_context: rdv_context1, user: user1,
                           rdv: rdv1, created_at: date, status: "seen")
  end

  # Second user : created 1 month ago, has a rdv_seen_delay_in_days present and the delay is more than 30 days
  # => not considered as oriented in less than 30 days
  let!(:user2) { create(:user, created_at: date) }
  let!(:rdv_context2) { create(:rdv_context, created_at: date, user: user2) }
  let!(:rdv2) { create(:rdv, created_at: date, starts_at: (date + 33.days), status: "seen") }
  let!(:participation2) do
    create(:participation, rdv_context: rdv_context2, user: user2,
                           rdv: rdv2, created_at: date, status: "seen")
  end

  # Third user : created 1 month ago, has no rdv_seen_delay_in_days present
  # => not considered as oriented in less than 30 days
  let!(:user3) { create(:user, created_at: date) }

  # Fourth user : everything okay but created less than 30 days ago
  # not taken into account in the computing
  let!(:user4) { create(:user, created_at: Time.zone.today) }
  let!(:rdv_context4) { create(:rdv_context, created_at: Time.zone.today, user: user4) }
  let!(:rdv4) { create(:rdv, created_at: Time.zone.today, starts_at: (Time.zone.today + 2.days), status: "seen") }
  let!(:participation4) do
    create(:participation, rdv_context: rdv_context4, user: user4,
                           rdv: rdv4, created_at: Time.zone.today, status: "seen")
  end

  let!(:rdv_context3) { create(:rdv_context, created_at: date, user: user3) }

  before do
    # this little time travel avoids bugs in the first days of march (because february is less than 30 days)
    travel_to(Time.zone.today + 3.days)
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
