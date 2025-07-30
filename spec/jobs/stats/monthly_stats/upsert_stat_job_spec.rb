describe Stats::MonthlyStats::UpsertStatJob, type: :service do
  subject do
    described_class.new.perform(structure_type, structure_id, from_date_string, until_date_string)
  end

  let!(:department) { create(:department) }
  let!(:from_date_string) { "2022-01-17 12:00:00 +0100" }
  let!(:until_date_string) { "2022-05-01 12:00:00 +0100" }
  let!(:date) { until_date_string.to_date }
  let!(:stat) { create(:stat, statable_type: "Department", statable_id: department.id) }
  let!(:structure_type) { "Department" }
  let!(:structure_id) { department.id }

  describe "#perform" do
    before do
      allow(Stat).to receive(:find_or_initialize_by)
        .and_return(stat)
    end

    context "when department" do
      it "finds or initializes stat record" do
        expect(Stat).to receive(:find_or_initialize_by)
          .with(statable_type: "Department", statable_id: department.id)
        subject
      end
    end

    context "when organisation" do
      let!(:organisation) { create(:organisation) }
      let!(:structure_type) { "Organisation" }
      let!(:structure_id) { organisation.id }

      it "finds or initializes stat record" do
        expect(Stat).to receive(:find_or_initialize_by)
          .with(statable_type: "Organisation", statable_id: organisation.id)
        subject
      end
    end

    it "calls ComputeAndSaveSingleStat for each Stat attribute for each month" do
      Stat::MONTHLY_STAT_ATTRIBUTES.each do |method_name|
        4.times do |i|
          expect(Stats::MonthlyStats::ComputeAndSaveSingleStatJob).to receive(:perform_later)
            .with(stat.id, method_name, from_date_string.to_date + i.month)
            .once
        end
      end

      subject
    end
  end
end
