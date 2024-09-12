describe Stats::MonthlyStats::UpsertStatsJob do
  subject do
    described_class.new.perform
  end

  let!(:department1) { create(:department) }
  let!(:department2) { create(:department) }
  let!(:department3) { create(:department) }

  let!(:organisation1) { create(:organisation, department: department1) }
  let!(:organisation2) { create(:organisation, department: department2) }

  describe "#perform" do
    before do
      allow(Stats::MonthlyStats::UpsertStatJob).to receive(:perform_later)
        .and_return(OpenStruct.new(success?: true))
    end

    it "calls the appropriate service the right number of times" do
      expect(Stats::MonthlyStats::UpsertStatJob).to receive(:perform_later).exactly(6).times
      subject
    end
  end
end
