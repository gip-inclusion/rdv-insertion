describe Stats::MonthlyStats::ComputeAndSaveSingleStatJob, type: :service do
  subject do
    described_class.new.perform(stat.id, method, date)
  end

  let!(:date) { "2022-05-01 12:00:00 +0100" }
  let!(:stat) { create(:stat, statable_type: "Department", statable_id: department.id) }
  let(:department) { create(:department) }
  let(:method) { "users_count_grouped_by_month" }

  let!(:stats_values) do
    {
      users_count_grouped_by_month: 5
    }
  end

  describe "#perform" do
    before do
      allow(Stats::MonthlyStats::ComputeForFocusedMonth).to receive(:new)
        .and_return(OpenStruct.new(stats_values))
    end

    it "computes and saves the single stat" do
      expect { subject }.to change { stat.reload[method] }.from({}).to({ "05/2022" => 5 })
    end

    context "over mutliple months" do
      it "computes and saves the single stat for each month" do
        allow(Stats::MonthlyStats::ComputeForFocusedMonth).to receive(:new)
          .and_return(OpenStruct.new({ users_count_grouped_by_month: 0 }))

        described_class.new.perform(stat.id, method, "2022-05-01 12:00:00 +0100")
        described_class.new.perform(stat.id, method, "2022-06-01 12:00:00 +0100")

        allow(Stats::MonthlyStats::ComputeForFocusedMonth).to receive(:new)
          .and_return(OpenStruct.new({ users_count_grouped_by_month: 4 }))

        described_class.new.perform(stat.id, method, "2022-07-01 12:00:00 +0100")
        described_class.new.perform(stat.id, method, "2022-08-01 12:00:00 +0100")

        expect(stat.reload[method]).to eq(
          {
            "07/2022" => 4,
            "08/2022" => 4
          }
        )
      end
    end
  end
end
