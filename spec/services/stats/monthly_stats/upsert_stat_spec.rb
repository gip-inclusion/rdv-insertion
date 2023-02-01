describe Stats::MonthlyStats::UpsertStat, type: :service do
  subject { described_class.call(department_number: department.number, date_string: date_string) }

  let!(:department) { create(:department) }
  let!(:date_string) { 1.month.ago.to_s }
  let!(:stats_attributes) do
    {
      applicants_count_grouped_by_month: {},
      rdvs_count_grouped_by_month: {},
      sent_invitations_count_grouped_by_month: {},
      percentage_of_no_show_grouped_by_month: {},
      average_time_between_invitation_and_rdv_in_days_by_month: {},
      average_time_between_rdv_creation_and_start_in_days_by_month: {},
      rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month: {},
      rate_of_autonomous_applicants_grouped_by_month: {}
    }
  end
  let!(:stat) { create(:stat, department_number: department.number) }

  describe "#call" do
    before do
      allow(Stats::MonthlyStats::ComputeForFocusedMonth).to receive(:call)
        .and_return(OpenStruct.new(success?: true, data: stats_attributes))
      allow(Stat).to receive(:find_or_initialize_by)
        .and_return(stat)
      allow(stat).to receive(:save)
        .and_return(true)
    end

    it "is a success" do
      expect(subject.success?).to eq(true)
    end

    it "finds or initializes stat record" do
      expect(Stat).to receive(:find_or_initialize_by)
        .with(department_number: department.number)
      subject
    end

    it "calls the compute stats service" do
      expect(Stats::MonthlyStats::ComputeForFocusedMonth).to receive(:call)
        .with(department_number: department.number, date: date_string.to_date)
      subject
    end

    it "saves a stat record" do
      expect(stat).to receive(:save)
      subject
    end
  end
end
