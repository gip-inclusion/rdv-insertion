describe Stats::MonthlyStats::ComputeForFocusedMonth, type: :service do
  subject { described_class.call(stat: stat, date: date) }

  let!(:stat) { create(:stat, statable_type: "Department", statable_id: department.id) }

  let(:date) { Time.zone.parse("17/03/2022 12:00") }
  let(:date_from_previous_month) { Time.zone.parse("17/02/2022 12:00") }

  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:user1) { create(:user, organisations: [organisation], created_at: date) }
  let!(:user2) { create(:user, organisations: [organisation], created_at: date_from_previous_month) }
  let!(:rdv1) { create(:rdv, created_at: date, organisation: organisation) }
  let!(:rdv2) { create(:rdv, created_at: date_from_previous_month, organisation: organisation) }
  let!(:participation1) { create(:participation, created_at: date, rdv: rdv1) }
  let!(:participation2) { create(:participation, created_at: date_from_previous_month, rdv: rdv2) }
  let!(:notification) { create(:notification, participation: participation2) }
  let!(:rdv_context1) { create(:rdv_context, created_at: date, user: user1) }
  let!(:rdv_context2) { create(:rdv_context, created_at: date_from_previous_month, user: user2) }
  let!(:invitation1) do
    create(:invitation, created_at: date, department: department)
  end
  let!(:invitation2) do
    create(:invitation, created_at: date_from_previous_month, department: department)
  end

  describe "#call" do
    before do
      allow(stat).to receive_messages(
        all_users: User.where(id: [user1, user2]),
        all_participations: Participation.where(id: [participation1, participation2]),
        invitations_sample: Invitation.where(id: [invitation1, invitation2]),
        participations_after_invitations_sample: Participation.where(id: [participation1]),
        participations_with_notifications_sample: Participation.where(id: [participation2]),
        rdv_contexts_with_invitations_and_participations_sample: RdvContext.where(id: [rdv_context1, rdv_context2]),
        users_sample: User.where(id: [user1, user2]),
        users_with_orientation_category_sample: User.where(id: [user1, user2]),
        orientation_rdv_contexts_sample: RdvContext.where(id: [rdv_context1, rdv_context2]),
        invited_users_sample: User.where(id: [user1, user2]),
        user_ids_with_rdv_sample: Participation.where(id: [participation1, participation2]).select(:user_id)
      )
      allow(Stats::ComputeRateOfNoShow).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 50.0))
      allow(Stats::ComputeAverageTimeBetweenInvitationAndRdvInDays).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 4.0))
      allow(Stats::ComputeRateOfUsersWithRdvSeenInLessThanThirtyDays).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 50.0))
      allow(Stats::ComputeRateOfUsersWithRdvSeen).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 50.0))
      allow(Stats::ComputeRateOfAutonomousUsers).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 50.0))
    end

    it "is a success" do
      expect(subject.success?).to eq(true)
    end

    it "renders a hash of stats" do
      expect(subject.stats_values).to be_a(Hash)
    end

    it "renders all the stats" do
      expect(subject.stats_values).to include(:users_count_grouped_by_month)
      expect(subject.stats_values).to include(:users_with_rdv_count_grouped_by_month)
      expect(subject.stats_values).to include(:rdvs_count_grouped_by_month)
      expect(subject.stats_values).to include(:sent_invitations_count_grouped_by_month)
      expect(subject.stats_values).to include(:rate_of_no_show_for_invitations_grouped_by_month)
      expect(subject.stats_values).to include(:rate_of_no_show_for_convocations_grouped_by_month)
      expect(subject.stats_values).to include(:average_time_between_invitation_and_rdv_in_days_by_month)
      expect(subject.stats_values).to include(:rate_of_users_oriented_in_less_than_30_days_by_month)
      expect(subject.stats_values).to include(:rate_of_users_oriented_grouped_by_month)
      expect(subject.stats_values).to include(:rate_of_autonomous_users_grouped_by_month)
    end

    it "renders the stats in the right format" do
      expect(subject.stats_values[:users_count_grouped_by_month]).to be_a(Integer)
      expect(subject.stats_values[:users_with_rdv_count_grouped_by_month]).to be_a(Integer)
      expect(subject.stats_values[:rdvs_count_grouped_by_month]).to be_a(Integer)
      expect(subject.stats_values[:sent_invitations_count_grouped_by_month]).to be_a(Integer)
      expect(subject.stats_values[:rate_of_no_show_for_invitations_grouped_by_month]).to be_a(Integer)
      expect(subject.stats_values[:rate_of_no_show_for_convocations_grouped_by_month]).to be_a(Integer)
      expect(subject.stats_values[:average_time_between_invitation_and_rdv_in_days_by_month]).to be_a(Integer)
      expect(subject.stats_values[:rate_of_users_oriented_in_less_than_30_days_by_month]).to be_a(Integer)
      expect(subject.stats_values[:rate_of_users_oriented_grouped_by_month]).to be_a(Integer)
      expect(subject.stats_values[:rate_of_autonomous_users_grouped_by_month]).to be_a(Integer)
    end

    it "counts the users for the focused month" do
      expect(stat).to receive(:all_users)
      # user1 is ok, user2 is not created in the focused month
      expect(subject.stats_values[:users_count_grouped_by_month]).to eq(1)
    end

    it "counts the users with rdv for the focused month" do
      expect(stat).to receive(:user_ids_with_rdv_sample)
      expect(subject.stats_values[:users_with_rdv_count_grouped_by_month]).to eq(1)
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

    it "computes the percentage of no show for invitations" do
      expect(stat).to receive(:participations_after_invitations_sample)
      expect(Stats::ComputeRateOfNoShow).to receive(:call)
      subject
    end

    it "computes the percentage of no show for convocations" do
      expect(stat).to receive(:participations_with_notifications_sample)
      expect(Stats::ComputeRateOfNoShow).to receive(:call)
      subject
    end

    it "computes the average time between first invitation and first rdv in days" do
      expect(stat).to receive(:rdv_contexts_with_invitations_and_participations_sample)
      expect(Stats::ComputeAverageTimeBetweenInvitationAndRdvInDays).to receive(:call)
        .with(rdv_contexts: [rdv_context1])
      subject
    end

    it "computes the percentage of users with rdv seen in less than 30 days" do
      expect(stat).to receive(:users_with_orientation_category_sample)
      expect(Stats::ComputeRateOfUsersWithRdvSeenInLessThanThirtyDays).to receive(:call)
        .with(users: [user2])
      subject
    end

    it "computes the percentage of users with rdv seen posterior to an invitation" do
      expect(stat).to receive(:orientation_rdv_contexts_sample)
      expect(Stats::ComputeRateOfUsersWithRdvSeen).to receive(:call)
        .with(rdv_contexts: [rdv_context1])
      subject
    end

    it "computes the percentage of invited users with at least on rdv taken in autonomy" do
      expect(stat).to receive(:invited_users_sample)
      expect(Stats::ComputeRateOfAutonomousUsers).to receive(:call)
        .with(users: [user1])
      subject
    end
  end
end
