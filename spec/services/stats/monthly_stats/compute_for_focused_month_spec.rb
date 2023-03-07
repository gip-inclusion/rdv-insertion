describe Stats::MonthlyStats::ComputeForFocusedMonth, type: :service do
  subject { described_class.call(stat: stat, date: date) }

  let!(:stat) { create(:stat, department_number: department.number) }

  let(:date) { Time.zone.parse("17/03/2022 12:00") }
  let(:date_from_previous_month) { Time.zone.parse("17/02/2022 12:00") }

  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:applicant1) { create(:applicant, department: department, created_at: date) }
  let!(:applicant2) { create(:applicant, department: department, created_at: date_from_previous_month) }
  let!(:rdv1) { create(:rdv, created_at: date, organisation: organisation) }
  let!(:rdv2) { create(:rdv, created_at: date_from_previous_month, organisation: organisation) }
  let!(:participation1) { create(:participation, created_at: date, rdv: rdv1) }
  let!(:participation2) { create(:participation, created_at: date_from_previous_month, rdv: rdv2) }
  let!(:rdv_context1) { create(:rdv_context, created_at: date, applicant: applicant1) }
  let!(:rdv_context2) { create(:rdv_context, created_at: date_from_previous_month, applicant: applicant2) }
  let!(:invitation1) do
    create(:invitation, sent_at: date, department: department)
  end
  let!(:invitation2) do
    create(:invitation, sent_at: date_from_previous_month, department: department)
  end

  describe "#call" do
    before do
      allow(stat).to receive(:all_applicants)
        .and_return(Applicant.where(id: [applicant1, applicant2]))
      allow(stat).to receive(:all_participations)
        .and_return(Participation.where(id: [participation1, participation2]))
      allow(stat).to receive(:invitations_sample)
        .and_return(Invitation.where(id: [invitation1, invitation2]))
      allow(stat).to receive(:participations_sample)
        .and_return(Participation.where(id: [participation1, participation2]))
      allow(stat).to receive(:rdv_contexts_sample)
        .and_return(RdvContext.where(id: [rdv_context1, rdv_context2]))
      allow(stat).to receive(:applicants_sample)
        .and_return(Applicant.where(id: [applicant1, applicant2]))
      allow(stat).to receive(:applicants_for_30_days_rdvs_seen_sample)
        .and_return(Applicant.where(id: [applicant1, applicant2]))
      allow(stat).to receive(:invited_applicants_with_rdvs_non_collectifs_sample)
        .and_return(Applicant.where(id: [applicant1, applicant2]))
      allow(stat).to receive(:rdvs_non_collectifs_sample)
        .and_return(Rdv.where(id: [rdv1, rdv2]))
      allow(Stats::ComputePercentageOfNoShow).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 50.0))
      allow(Stats::ComputeAverageTimeBetweenInvitationAndRdvInDays).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 4.0))
      allow(Stats::ComputeAverageTimeBetweenParticipationCreationAndRdvStartInDays).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 4.0))
      allow(Stats::ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 50.0))
      allow(Stats::ComputeRateOfAutonomousApplicants).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 50.0))
    end

    it "is a success" do
      expect(subject.success?).to eq(true)
    end

    it "renders a hash of stats" do
      expect(subject.stats_values).to be_a(Hash)
    end

    it "renders all the stats" do
      expect(subject.stats_values).to include(:applicants_count_grouped_by_month)
      expect(subject.stats_values).to include(:rdvs_count_grouped_by_month)
      expect(subject.stats_values).to include(:sent_invitations_count_grouped_by_month)
      expect(subject.stats_values).to include(:percentage_of_no_show_grouped_by_month)
      expect(subject.stats_values).to include(:average_time_between_invitation_and_rdv_in_days_by_month)
      expect(subject.stats_values).to include(:average_time_between_rdv_creation_and_start_in_days_by_month)
      expect(subject.stats_values).to include(:rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month)
      expect(subject.stats_values).to include(:rate_of_autonomous_applicants_grouped_by_month)
    end

    it "renders the stats in the right format" do
      expect(subject.stats_values[:applicants_count_grouped_by_month]).to be_a(Integer)
      expect(subject.stats_values[:rdvs_count_grouped_by_month]).to be_a(Integer)
      expect(subject.stats_values[:sent_invitations_count_grouped_by_month]).to be_a(Integer)
      expect(subject.stats_values[:percentage_of_no_show_grouped_by_month]).to be_a(Integer)
      expect(subject.stats_values[:average_time_between_invitation_and_rdv_in_days_by_month]).to be_a(Integer)
      expect(subject.stats_values[:average_time_between_rdv_creation_and_start_in_days_by_month]).to be_a(Integer)
      expect(subject.stats_values[:rate_of_applicants_with_rdv_seen_in_less_than_30_days_by_month]).to be_a(Integer)
      expect(subject.stats_values[:rate_of_autonomous_applicants_grouped_by_month]).to be_a(Integer)
    end

    it "counts the applicants for the focused month" do
      expect(stat).to receive(:all_applicants)
      # applicant1 is ok, applicant2 is not created in the focused month
      expect(subject.stats_values[:applicants_count_grouped_by_month]).to eq(1)
    end

    it "counts the rdvs for the focused month" do
      expect(stat).to receive(:all_participations)
      # rdv1 is ok, rdv2 is not created in the focused month
      expect(subject.stats_values[:rdvs_count_grouped_by_month]).to eq(1)
    end

    it "counts the sent invitations for the focused month" do
      expect(stat).to receive(:invitations_sample)
      # invitation1 is ok, invitation2 is not sent in the focused month
      expect(subject.stats_values[:sent_invitations_count_grouped_by_month]).to eq(1)
    end

    it "computes the percentage of no show" do
      expect(stat).to receive(:participations_sample)
      expect(Stats::ComputePercentageOfNoShow).to receive(:call)
        .with(participations: [participation1])
      subject
    end

    it "computes the average time between first invitation and first rdv in days" do
      expect(stat).to receive(:rdv_contexts_sample)
      expect(Stats::ComputeAverageTimeBetweenInvitationAndRdvInDays).to receive(:call)
        .with(rdv_contexts: [rdv_context1])
      subject
    end

    it "computes the average time between the creation of the rdvs and the rdvs date in days" do
      expect(stat).to receive(:participations_sample)
      expect(Stats::ComputeAverageTimeBetweenParticipationCreationAndRdvStartInDays).to receive(:call)
        .with(participations: [participation1])
      subject
    end

    it "computes the percentage of applicants with rdv seen in less than 30 days" do
      expect(stat).to receive(:applicants_for_30_days_rdvs_seen_sample)
      expect(Stats::ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays).to receive(:call)
        .with(applicants: [applicant2])
      subject
    end

    it "computes the percentage of invited applicants with at least on rdv taken in autonomy" do
      expect(stat).to receive(:invited_applicants_with_rdvs_non_collectifs_sample)
      expect(stat).to receive(:rdvs_non_collectifs_sample)
      expect(Stats::ComputeRateOfAutonomousApplicants).to receive(:call)
        .with(applicants: [applicant1],
              rdvs: [rdv1])
      subject
    end
  end
end
