describe Stats::MonthlyStats::ComputeForFocusedMonth, type: :service do
  subject { described_class.call(department_number: department.number, date: date) }

  let!(:department) { create(:department) }
  let!(:date) { 1.month.ago }

  let!(:first_day_of_last_month) { 1.month.ago.beginning_of_month }
  let!(:first_day_of_other_month) { 2.months.ago.beginning_of_month }
  let!(:results_keys) { [date.strftime("%m/%Y")] }

  let!(:applicant1) { create(:applicant, department: department, created_at: first_day_of_last_month) }
  let!(:applicant2) { create(:applicant, department: department, created_at: first_day_of_other_month) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:rdv1) { create(:rdv, created_at: first_day_of_last_month, organisation: organisation) }
  let!(:rdv2) { create(:rdv, created_at: first_day_of_other_month, organisation: organisation) }
  let!(:rdv_context1) { create(:rdv_context, created_at: first_day_of_last_month, applicant: applicant1) }
  let!(:rdv_context2) { create(:rdv_context, created_at: first_day_of_other_month, applicant: applicant2) }
  let!(:invitation1) do
    create(:invitation, created_at: first_day_of_last_month, sent_at: first_day_of_last_month, department: department)
  end
  let!(:invitation2) do
    create(:invitation, created_at: first_day_of_other_month, sent_at: first_day_of_other_month, department: department)
  end

  describe "#call" do
    before do
      allow(Stats::RetrieveRecordsForStatsComputing).to receive(:call)
        .and_return(OpenStruct.new(
                      success?: true,
                      data: {
                        all_applicants: department.applicants,
                        all_rdvs: department.rdvs,
                        sent_invitations: department.invitations,
                        relevant_rdvs: department.rdvs,
                        relevant_rdv_contexts: department.rdv_contexts,
                        relevant_applicants: department.applicants
                      }
                    ))
      allow(Stats::ComputePercentageOfNoShow).to receive(:call)
        .and_return(OpenStruct.new(success?: true, data: 50.0))
      allow(Stats::ComputeAverageTimeBetweenInvitationAndRdvInDays).to receive(:call)
        .and_return(OpenStruct.new(success?: true, data: 4.0))
      allow(Stats::ComputeAverageTimeBetweenRdvCreationAndStartInDays).to receive(:call)
        .and_return(OpenStruct.new(success?: true, data: 4.0))
      allow(Stats::ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays).to receive(:call)
        .and_return(OpenStruct.new(success?: true, data: 50.0))
      allow(Stats::ComputeRateOfAutonomousApplicants).to receive(:call)
        .and_return(OpenStruct.new(success?: true, data: 50.0))
    end

    it "is a success" do
      expect(subject.success?).to eq(true)
    end

    it "renders a hash of stats" do
      expect(subject.data).to be_a(Hash)
    end

    it "renders all the stats" do
      expect(subject.data).to include(:applicants_count_grouped_by_month)
      expect(subject.data).to include(:rdvs_count_grouped_by_month)
      expect(subject.data).to include(:sent_invitations_count_grouped_by_month)
      expect(subject.data).to include(:percentage_of_no_show_grouped_by_month)
      expect(subject.data).to include(:average_time_between_invitation_and_rdv_in_days_by_month)
      expect(subject.data).to include(:average_time_between_rdv_creation_and_start_in_days_by_month)
      expect(subject.data).to include(:rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month)
      expect(subject.data).to include(:rate_of_autonomous_applicants_grouped_by_month)
    end

    it "renders the stats in the right format" do
      expect(subject.data[:applicants_count_grouped_by_month]).to be_a(Hash)
      expect(subject.data[:rdvs_count_grouped_by_month]).to be_a(Hash)
      expect(subject.data[:sent_invitations_count_grouped_by_month]).to be_a(Hash)
      expect(subject.data[:percentage_of_no_show_grouped_by_month]).to be_a(Hash)
      expect(subject.data[:average_time_between_invitation_and_rdv_in_days_by_month]).to be_a(Hash)
      expect(subject.data[:average_time_between_rdv_creation_and_start_in_days_by_month]).to be_a(Hash)
      expect(subject.data[:rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month]).to be_a(Hash)
      expect(subject.data[:rate_of_autonomous_applicants_grouped_by_month]).to be_a(Hash)

      expect(subject.data[:applicants_count_grouped_by_month].keys).to eq(results_keys)
      expect(subject.data[:rdvs_count_grouped_by_month].keys).to eq(results_keys)
      expect(subject.data[:sent_invitations_count_grouped_by_month].keys).to eq(results_keys)
      expect(subject.data[:percentage_of_no_show_grouped_by_month].keys).to eq(results_keys)
      expect(subject.data[:average_time_between_invitation_and_rdv_in_days_by_month].keys).to eq(results_keys)
      expect(subject.data[:average_time_between_rdv_creation_and_start_in_days_by_month].keys).to eq(results_keys)
      expect(subject.data[:rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month].keys).to eq(results_keys)
      expect(subject.data[:rate_of_autonomous_applicants_grouped_by_month].keys).to eq(results_keys)
    end

    it "retrieves the relevant records in order to compute the stats" do
      expect(Stats::RetrieveRecordsForStatsComputing).to receive(:call)
        .with(department_number: department.number)
      subject
    end

    it "counts the applicants for the focused month" do
      # applicant1 is ok, applicant2 is not created in the focused month
      expect(subject.data[:applicants_count_grouped_by_month].values).to eq([1])
    end

    it "counts the rdvs for the focused month" do
      # rdv1 is ok, rdv2 is not created in the focused month
      expect(subject.data[:rdvs_count_grouped_by_month].values).to eq([1])
    end

    it "counts the sent invitations for the focused month" do
      # invitation1 is ok, invitation2 is not sent in the focused month
      expect(subject.data[:sent_invitations_count_grouped_by_month].values).to eq([1])
    end

    it "computes the percentage of no show" do
      expect(Stats::ComputePercentageOfNoShow).to receive(:call)
        .with(rdvs: department.rdvs, for_focused_month: true, date: date)
      subject
    end

    it "computes the average time between first invitation and first rdv in days" do
      expect(Stats::ComputeAverageTimeBetweenInvitationAndRdvInDays).to receive(:call)
        .with(rdv_contexts: department.rdv_contexts, for_focused_month: true, date: date)
      subject
    end

    it "computes the average time between the creation of the rdvs and the rdvs date in days" do
      expect(Stats::ComputeAverageTimeBetweenRdvCreationAndStartInDays).to receive(:call)
        .with(rdvs: department.rdvs, for_focused_month: true, date: date)
      subject
    end

    it "computes the percentage of applicants with rdv seen in less than 30 days" do
      expect(Stats::ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays).to receive(:call)
        .with(applicants: department.applicants, for_focused_month: true, date: date)
      subject
    end

    it "computes the percentage of invited applicants with at least on rdv taken in autonomy" do
      expect(Stats::ComputeRateOfAutonomousApplicants).to receive(:call)
        .with(applicants: department.applicants, rdvs: department.rdvs,
              sent_invitations: department.invitations, for_focused_month: true, date: date)
      subject
    end
  end
end
