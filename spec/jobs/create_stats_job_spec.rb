describe CreateStatsJob, type: :job do
  subject do
    described_class.new.perform
  end

  let!(:department1) { create(:department) }
  let!(:department2) { create(:department) }
  let!(:department3) { create(:department) }

  describe "#perform" do
    before do
      allow(Stats::CreateStat).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
    end

    it "calls the appropriate service the right number of times" do
      expect(Stats::CreateStat).to receive(:call).exactly(4).times
      subject
    end

    context "when the service fails" do
      before do
        allow(Stats::CreateStat).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["something happened"]))
      end

      it "raises an error" do
        expect { subject }.to raise_error(StatsJobError, "something happened")
      end
    end
  end
end
