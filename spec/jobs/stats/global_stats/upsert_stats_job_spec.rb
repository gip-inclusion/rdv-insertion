describe Stats::GlobalStats::UpsertStatsJob do
  subject do
    described_class.new.perform
  end

  let!(:department1) { create(:department) }
  let!(:department2) { create(:department) }
  let!(:department3) { create(:department) }

  describe "#perform" do
    before do
      allow(Stats::GlobalStats::UpsertStatJob).to receive(:perform_async)
        .and_return(OpenStruct.new(success?: true))
    end

    it "calls the appropriate service the right number of times" do
      expect(Stats::GlobalStats::UpsertStatJob).to receive(:perform_async).exactly(4).times
      subject
    end
  end
end
