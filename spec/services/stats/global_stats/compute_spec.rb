describe Stats::GlobalStats::Compute, type: :service do
  subject { described_class.call(department_number: department.number) }

  let!(:department) { create(:department) }
  let!(:other_organisation) { create(:organisation) }

  let!(:first_day_of_last_month) { 1.month.ago.beginning_of_month }
  let!(:first_day_of_other_month) { 2.months.ago.beginning_of_month }

  let!(:organisation) { create(:organisation, department: department) }
  let!(:applicant1) { create(:applicant, department: department, created_at: first_day_of_last_month) }
  let!(:applicant2) { create(:applicant, department: department, created_at: first_day_of_other_month) }
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
  let!(:agent) { create(:agent, organisations: [organisation]) }

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
                        relevant_applicants: department.applicants,
                        relevant_agents: department.agents
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
      expect(subject.data).to include(:applicants_count)
      expect(subject.data).to include(:rdvs_count)
      expect(subject.data).to include(:sent_invitations_count)
      expect(subject.data).to include(:percentage_of_no_show)
      expect(subject.data).to include(:average_time_between_invitation_and_rdv_in_days)
      expect(subject.data).to include(:average_time_between_rdv_creation_and_start_in_days)
      expect(subject.data).to include(:rate_of_applicants_with_rdv_seen_in_less_than_30_days)
      expect(subject.data).to include(:rate_of_autonomous_applicants)
      expect(subject.data).to include(:agents_count)
    end

    it "renders the stats in the right format" do
      expect(subject.data[:applicants_count]).to be_a(Integer)
      expect(subject.data[:rdvs_count]).to be_a(Integer)
      expect(subject.data[:sent_invitations_count]).to be_a(Integer)
      expect(subject.data[:percentage_of_no_show]).to be_a(Float)
      expect(subject.data[:average_time_between_invitation_and_rdv_in_days]).to be_a(Float)
      expect(subject.data[:average_time_between_rdv_creation_and_start_in_days]).to be_a(Float)
      expect(subject.data[:rate_of_applicants_with_rdv_seen_in_less_than_30_days]).to be_a(Float)
      expect(subject.data[:rate_of_autonomous_applicants]).to be_a(Float)
      expect(subject.data[:agents_count]).to be_a(Integer)
    end

    it "retrieves the relevant records in order to compute the stats" do
      expect(Stats::RetrieveRecordsForStatsComputing).to receive(:call)
        .with(department_number: department.number)
      subject
    end

    it "counts the applicants" do
      expect(subject.data[:applicants_count]).to eq(2)
    end

    it "counts the rdvs" do
      expect(subject.data[:rdvs_count]).to eq(2)
    end

    it "counts the sent invitations" do
      expect(subject.data[:sent_invitations_count]).to eq(2)
    end

    it "computes the percentage of no show" do
      expect(Stats::ComputePercentageOfNoShow).to receive(:call)
        .with(rdvs: department.rdvs)
      subject
    end

    it "computes the average time between first invitation and first rdv in days" do
      expect(Stats::ComputeAverageTimeBetweenInvitationAndRdvInDays).to receive(:call)
        .with(rdv_contexts: department.rdv_contexts)
      subject
    end

    it "computes the average time between the creation of the rdvs and the rdvs date in days" do
      expect(Stats::ComputeAverageTimeBetweenRdvCreationAndStartInDays).to receive(:call)
        .with(rdvs: department.rdvs)
      subject
    end

    it "computes the percentage of applicants with rdv seen in less than 30 days" do
      expect(Stats::ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays).to receive(:call)
        .with(applicants: department.applicants)
      subject
    end

    it "computes the percentage of invited applicants with at least on rdv taken in autonomy" do
      expect(Stats::ComputeRateOfAutonomousApplicants).to receive(:call)
        .with(applicants: department.applicants, rdvs: department.rdvs,
              sent_invitations: department.invitations)
      subject
    end

    it "counts the agents" do
      expect(subject.data[:agents_count]).to eq(1)
    end
  end
end
