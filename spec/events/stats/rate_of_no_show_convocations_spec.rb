describe Stats::RateOfNoShowConvocations do
  let(:number_of_seen) { Stats::Counters::NumberOfConvocationsSeen }
  let(:number_of_no_show) { Stats::Counters::NumberOfConvocationsNoShow }

  before do
    Redis.new.flushall
  end

  describe "counter" do
    context "when participation is updated" do
      it "changes counter" do
        Sidekiq::Testing.inline! do
          participation = create(:participation, status: "noshow")
          participation2 = create(:participation, status: "noshow", rdv: participation.rdv)
          create(:notification, participation: participation)
          create(:notification, participation: participation2)

          participation.update!(status: "seen")
          expect(number_of_seen.value(scope: participation.department)).to eq(1)

          participation.update!(status: "noshow")
          expect(number_of_seen.value(scope: participation.department)).to eq(0)
          expect(number_of_no_show.value(scope: participation.department)).to eq(1)

          participation2.update!(status: "seen")
          expect(number_of_seen.value(scope: participation.department)).to eq(1)
          expect(number_of_no_show.value(scope: participation.department)).to eq(1)
          expect(described_class.value(scope: participation.department)).to eq(50.0)
        end
      end
    end

    context "monthly counter" do
      it "changes relevant counter" do
        Sidekiq::Testing.inline! do
          participation = create(:participation, status: "seen")
          participation2 = create(:participation, status: "noshow")
          participation3 = create(:participation, status: "noshow")
          participation4 = create(:participation, status: "noshow")

          create(:notification, participation: participation)
          create(:notification, participation: participation2)
          create(:notification, participation: participation3)
          create(:notification, participation: participation4)

          participation.update!(status: "noshow", created_at: 1.month.ago)
          participation2.update!(status: "seen", created_at: 2.months.ago)
          participation3.update!(status: "seen", created_at: 2.months.ago)
          participation4.update!(status: "seen", created_at: 2.months.ago)
          participation4.update!(status: "noshow")

          expect(number_of_no_show.value(scope: participation.department,
                                         month: 1.month.ago.strftime("%Y-%m"))).to eq(1)
          expect(number_of_seen.value(scope: Department.new,
                                      month: 2.months.ago.strftime("%Y-%m"))).to eq(2)
          expect(number_of_no_show.value(scope: participation4.department,
                                         month: 2.months.ago.strftime("%Y-%m"))).to eq(1)
          expect(number_of_seen.value(scope: Department.new)).to eq(2)
          expect(described_class.value(scope: Department.new)).to eq(50)
          values_grouped_by_month = described_class.values_grouped_by_month(scope: Department.new)

          expect(values_grouped_by_month[1.month.ago.strftime("%m/%Y").to_s].round).to eq(100)
          expect(values_grouped_by_month[2.months.ago.strftime("%m/%Y").to_s].round).to eq(33)
        end
      end
    end
  end
end
