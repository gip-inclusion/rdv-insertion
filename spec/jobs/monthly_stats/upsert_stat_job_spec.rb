describe MonthlyStats::UpsertStatJob do
  subject do
    described_class.new.perform(department.number, date_string)
  end

  let!(:department) { create(:department) }
  let!(:date_string) { 1.month.ago.to_s }

  describe "#perform" do
    before do
      allow(Stats::MonthlyStats::UpsertStat).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
    end

    it "calls the appropriate service" do
      expect(Stats::MonthlyStats::UpsertStat).to receive(:call)
        .with(department_number: department.number, date_string: date_string)
      subject
    end

    context "when the service fails" do
      before do
        allow(Stats::MonthlyStats::UpsertStat).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["something happened"]))
      end

      it "raises an error" do
        expect { subject }.to raise_error(StatsJobError, "something happened")
      end
    end
  end
end
