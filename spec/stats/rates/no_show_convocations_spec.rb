describe Rates::NoShowConvocations do
  let(:number_of_seen) { Counters::NumberOfConvocationsSeen }
  let(:number_of_no_show) { Counters::NumberOfConvocationsNoShow }

  before do
    Redis.new.flushall
  end

  describe "counter" do
    context "when participation is updated" do
      it "changes counter" do
        Sidekiq::Testing.inline! do
          participation = create(:participation, status: "noshow")
          participation2 = create(:participation, status: "noshow", rdv: participation.rdv)
          create(:notification, participation: participation, sent_at: 1.month.ago)
          create(:notification, participation: participation2, sent_at: 1.month.ago)

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

          create(:notification, participation: participation, sent_at: 1.month.ago)
          create(:notification, participation: participation2, sent_at: 2.months.ago)
          create(:notification, participation: participation3, sent_at: 2.months.ago)
          create(:notification, participation: participation4, sent_at: 2.months.ago)

          participation.update!(status: "noshow", created_at: 1.month.ago)
          participation2.update!(status: "seen", created_at: 2.months.ago)
          participation3.update!(status: "seen", created_at: 2.months.ago)
          participation4.update!(status: "seen", created_at: 2.months.ago)
          participation4.update!(status: "noshow")

          expect(number_of_no_show.value(scope: participation.department,
                                         month: 1.month.ago)).to eq(1)
          expect(number_of_seen.value(month: 2.months.ago)).to eq(2)
          expect(number_of_no_show.value(scope: participation4.department,
                                         month: 2.months.ago)).to eq(1)
          expect(number_of_seen.value).to eq(2)
          expect(described_class.value).to eq(50)
          values_grouped_by_month = described_class.values_grouped_by_month

          expect(values_grouped_by_month[1.month.ago.strftime("%m/%Y").to_s].round).to eq(100)
          expect(values_grouped_by_month[2.months.ago.strftime("%m/%Y").to_s].round).to eq(33)
        end
      end
    end
  end
end
