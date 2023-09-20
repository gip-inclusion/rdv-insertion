describe Stats::GlobalStats::Compute, type: :service do
  subject { described_class.call(stat: stat) }

  let!(:stat) { create(:stat, statable_type: "Department", statable_id: department.id) }

  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:applicant1) { create(:applicant, organisations: [organisation]) }
  let!(:applicant2) { create(:applicant, organisations: [organisation]) }
  let!(:rdv1) { create(:rdv, organisation: organisation) }
  let!(:rdv2) { create(:rdv, organisation: organisation) }
  let!(:participation1) { create(:participation, rdv: rdv1) }
  let!(:participation2) { create(:participation, rdv: rdv2) }
  let!(:notification) { create(:notification, participation: participation2) }
  let!(:rdv_context1) { create(:rdv_context, applicant: applicant1) }
  let!(:rdv_context2) { create(:rdv_context, applicant: applicant2) }
  let!(:invitation1) { create(:invitation, department: department) }
  let!(:invitation2) { create(:invitation, department: department) }
  let!(:agent) { create(:agent, organisations: [organisation]) }

  describe "#call" do
    before do
      allow(stat).to receive(:all_applicants)
        .and_return(Applicant.where(id: [applicant1, applicant2]))
      allow(stat).to receive(:all_participations)
        .and_return(Participation.where(id: [participation1, participation2]))
      allow(stat).to receive(:invitations_sample)
        .and_return(Invitation.where(id: [invitation1, invitation2]))
      allow(stat).to receive(:participations_without_notifications_sample)
        .and_return(Participation.where(id: [participation1]))
      allow(stat).to receive(:participations_with_notifications_sample)
        .and_return(Participation.where(id: [participation2]))
      allow(stat).to receive(:rdv_contexts_sample)
        .and_return(RdvContext.where(id: [rdv_context1, rdv_context2]))
      allow(stat).to receive(:applicants_sample)
        .and_return(Applicant.where(id: [applicant1, applicant2]))
      allow(stat).to receive(:applicants_for_30_days_rdvs_seen_sample)
        .and_return(Applicant.where(id: [applicant1, applicant2]))
      allow(stat).to receive(:invited_applicants_sample)
        .and_return(Applicant.where(id: [applicant1, applicant2]))
      allow(stat).to receive(:agents_sample)
        .and_return(Agent.where(id: [agent]))
      allow(Stats::ComputeRateOfNoShow).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 50.0))
      allow(Stats::ComputeAverageTimeBetweenInvitationAndRdvInDays).to receive(:call)
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
      expect(subject.stat_attributes).to be_a(Hash)
    end

    it "renders all the stats" do
      expect(subject.stat_attributes).to include(:applicants_count)
      expect(subject.stat_attributes).to include(:rdvs_count)
      expect(subject.stat_attributes).to include(:sent_invitations_count)
      expect(subject.stat_attributes).to include(:rate_of_no_show_for_invitations)
      expect(subject.stat_attributes).to include(:rate_of_no_show_for_convocations)
      expect(subject.stat_attributes).to include(:average_time_between_invitation_and_rdv_in_days)
      expect(subject.stat_attributes).to include(:rate_of_applicants_with_rdv_seen_in_less_than_30_days)
      expect(subject.stat_attributes).to include(:rate_of_autonomous_applicants)
      expect(subject.stat_attributes).to include(:agents_count)
    end

    it "renders the stats in the right format" do
      expect(subject.stat_attributes[:applicants_count]).to be_a(Integer)
      expect(subject.stat_attributes[:rdvs_count]).to be_a(Integer)
      expect(subject.stat_attributes[:sent_invitations_count]).to be_a(Integer)
      expect(subject.stat_attributes[:rate_of_no_show_for_invitations]).to be_a(Float)
      expect(subject.stat_attributes[:rate_of_no_show_for_convocations]).to be_a(Float)
      expect(subject.stat_attributes[:average_time_between_invitation_and_rdv_in_days]).to be_a(Float)
      expect(subject.stat_attributes[:rate_of_applicants_with_rdv_seen_in_less_than_30_days]).to be_a(Float)
      expect(subject.stat_attributes[:rate_of_autonomous_applicants]).to be_a(Float)
      expect(subject.stat_attributes[:agents_count]).to be_a(Integer)
    end

    it "counts the applicants" do
      expect(stat).to receive(:all_applicants)
      expect(subject.stat_attributes[:applicants_count]).to eq(2)
    end

    it "counts the rdvs" do
      expect(stat).to receive(:all_participations)
      expect(subject.stat_attributes[:rdvs_count]).to eq(2)
    end

    it "counts the sent invitations" do
      expect(stat).to receive(:invitations_sample)
      expect(subject.stat_attributes[:sent_invitations_count]).to eq(2)
    end

    it "computes the percentage of no show for invitations" do
      expect(stat).to receive(:participations_without_notifications_sample)
      expect(Stats::ComputeRateOfNoShow).to receive(:call)
        .with(participations: [participation1])
      subject
    end

    it "computes the percentage of no show for convocations" do
      expect(stat).to receive(:participations_with_notifications_sample)
      expect(Stats::ComputeRateOfNoShow).to receive(:call)
        .with(participations: [participation2])
      subject
    end

    it "computes the average time between first invitation and first rdv in days" do
      expect(stat).to receive(:rdv_contexts_sample)
      expect(Stats::ComputeAverageTimeBetweenInvitationAndRdvInDays).to receive(:call)
        .with(rdv_contexts: [rdv_context1, rdv_context2])
      subject
    end

    it "computes the percentage of applicants with rdv seen in less than 30 days" do
      expect(stat).to receive(:applicants_for_30_days_rdvs_seen_sample)
      expect(Stats::ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays).to receive(:call)
        .with(applicants: [applicant1, applicant2])
      subject
    end

    it "computes the percentage of invited applicants with at least on rdv taken in autonomy" do
      expect(stat).to receive(:invited_applicants_sample)
      expect(Stats::ComputeRateOfAutonomousApplicants).to receive(:call)
        .with(applicants: [applicant1, applicant2])
      subject
    end

    it "counts the agents" do
      expect(stat).to receive(:agents_sample)
      expect(subject.stat_attributes[:agents_count]).to eq(1)
    end
  end
end
