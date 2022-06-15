describe Stats::CreateStat, type: :service do
  subject { described_class.call(department_id: department.id) }

  let!(:department) { create(:department) }
  let!(:stats_data) do
    {
      applicants_count: 0,
      applicants_count_grouped_by_month: {},
      rdvs_count: 0,
      rdvs_count_grouped_by_month: {},
      sent_invitations_count: 0,
      sent_invitations_count_grouped_by_month: {},
      percentage_of_no_show: 0.0,
      percentage_of_no_show_grouped_by_month: {},
      average_time_between_invitation_and_rdv_in_days: 0.0,
      average_time_between_invitation_and_rdv_in_days_by_month: {},
      average_time_between_rdv_creation_and_start_in_days: 0.0,
      average_time_between_rdv_creation_and_start_in_days_by_month: {},
      rate_of_applicants_with_rdv_seen_in_less_than_30_days: 0.0,
      rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month: {},
      agents_count: 1,
      department_id: department.id
    }
  end
  let!(:stat) { create(:stat, department_id: department.id) }

  describe "#call" do
    before do
      allow(Stats::ComputeStats).to receive(:call)
        .with(department_id: department.id)
        .and_return(OpenStruct.new(success?: true, data: stats_data))
      allow(Stat).to receive(:new)
        .with(stats_data)
        .and_return(stat)
      allow(stat).to receive(:save)
        .and_return(true)
    end

    it "is a success" do
      expect(subject.success?).to eq(true)
    end

    it "initializes a new stat record" do
      expect(Stat).to receive(:new)
      subject
    end

    it "calls the compute stats service" do
      expect(Stats::ComputeStats).to receive(:call)
      subject
    end

    it "saves a stat record" do
      expect(stat).to receive(:save)
      subject
    end

    it "returns a stat record" do
      expect(subject.stat).to eq(stat)
    end
  end
end
