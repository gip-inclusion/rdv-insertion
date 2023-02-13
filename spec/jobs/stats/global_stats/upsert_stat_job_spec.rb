describe Stats::GlobalStats::UpsertStatJob do
  subject do
    described_class.new.perform(department.number)
  end

  let!(:department) { create(:department) }

  describe "#perform" do
    before do
      allow(Stats::GlobalStats::UpsertStat).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
    end

    it "calls the appropriate service" do
      expect(Stats::GlobalStats::UpsertStat).to receive(:call)
        .with(department_number: department.number)
      subject
    end

    context "when the service fails" do
      before do
        allow(Stats::GlobalStats::UpsertStat).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["something happened"]))
      end

      it "raises an error" do
        expect { subject }.to raise_error(StatsJobError, "something happened")
      end
    end
  end
end
