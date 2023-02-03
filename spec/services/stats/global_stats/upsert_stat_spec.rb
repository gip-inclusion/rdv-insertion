describe Stats::GlobalStats::UpsertStat, type: :service do
  subject { described_class.call(department_number: department.number) }

  let!(:department) { create(:department) }
  let!(:stat_attributes) do
    {
      applicants_count: 0,
      rdvs_count: 0,
      sent_invitations_count: 0,
      percentage_of_no_show: 0.0,
      average_time_between_invitation_and_rdv_in_days: 0.0,
      average_time_between_rdv_creation_and_start_in_days: 0.0,
      rate_of_applicants_with_rdv_seen_in_less_than_30_days: 0.0,
      rate_of_autonomous_applicants: 0.0,
      agents_count: 1
    }
  end
  let!(:stat) { create(:stat, department_number: department.number) }

  describe "#call" do
    before do
      allow(Stats::GlobalStats::Compute).to receive(:call)
        .and_return(OpenStruct.new(success?: true, stat_attributes: stat_attributes))
      allow(Stat).to receive(:find_or_initialize_by)
        .and_return(stat)
      allow(stat).to receive(:assign_attributes)
        .and_return(true)
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
      expect(Stats::GlobalStats::Compute).to receive(:call)
        .with(stat: stat)
      subject
    end

    it "assigns the stat_attributes to a stat record" do
      expect(stat).to receive(:assign_attributes)
        .with(stat_attributes)
      subject
    end

    it "saves a stat record" do
      expect(stat).to receive(:save)
      subject
    end
  end
end
