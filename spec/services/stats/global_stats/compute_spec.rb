describe Stats::GlobalStats::Compute, type: :service do
  subject { described_class.new(stat: stat) }

  let!(:stat) { create(:stat, statable_type: "Department", statable_id: department.id) }

  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:user1) { create(:user, organisations: [organisation]) }
  let!(:user2) { create(:user, organisations: [organisation]) }
  let!(:rdv1) { create(:rdv, organisation: organisation) }
  let!(:rdv2) { create(:rdv, organisation: organisation) }
  let!(:participation1) { create(:participation, rdv: rdv1) }
  let!(:participation2) { create(:participation, rdv: rdv2) }
  let!(:notification) { create(:notification, participation: participation2) }
  let!(:follow_up1) { create(:follow_up, user: user1) }
  let!(:follow_up2) { create(:follow_up, user: user2) }
  let!(:invitation1) { create(:invitation, department: department) }
  let!(:invitation2) { create(:invitation, department: department) }
  let!(:agent) { create(:agent, organisations: [organisation]) }

  describe "#call" do
    before do
      allow(stat).to receive_messages(
        all_users: User.where(id: [user1, user2]),
        all_participations: Participation.where(id: [participation1, participation2]),
        invitations_set: Invitation.where(id: [invitation1, invitation2]),
        participations_set: Participation.where(id: [participation1, participation2]),
        participations_after_invitations_set: Participation.where(id: [participation1]),
        participations_with_notifications_set: Participation.where(id: [participation2]),
        users_set: User.where(id: [user1, user2]),
        users_first_orientation_follow_up: FollowUp.where(id: [follow_up1, follow_up2]),
        users_first_accompaniement_follow_up: FollowUp.where(id: [follow_up1, follow_up2]),
        orientation_follow_ups_with_invitations: FollowUp.where(id: [follow_up1, follow_up2]),
        invited_users_set: User.where(id: [user1, user2]),
        agents_set: Agent.where(id: [agent]),
        user_ids_with_rdv_set: Participation.where(id: [participation1, participation2]).select(:user_id)
      )
      allow(Stats::ComputeRateOfNoShow).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 50.0))
      allow(Stats::ComputeAverageTimeBetweenInvitationAndRdvInDays).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 4.0))
      allow(Stats::ComputeFollowUpSeenRateWithinDelays).to receive(:call)
        .with(follow_ups: stat.users_first_orientation_follow_up, target_delay_days: 45)
        .and_return(OpenStruct.new(success?: true, value: 50.0))
      allow(Stats::ComputeFollowUpSeenRateWithinDelays).to receive(:call)
        .with(
          follow_ups: stat.users_first_accompaniement_follow_up,
          target_delay_days: 30,
          consider_orientation_rdv_as_start: true
        )
        .and_return(OpenStruct.new(success?: true, value: 25.0))
      allow(Stats::ComputeRateOfUsersWithRdvSeen).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 50.0))
      allow(Stats::ComputeRateOfAutonomousUsers).to receive(:call)
        .and_return(OpenStruct.new(success?: true, value: 50.0))
    end

    it "renders the stats in the right format" do
      expect(subject.users_count).to be_a(Integer)
      expect(subject.users_with_rdv_count).to be_a(Integer)
      expect(subject.rdvs_count).to be_a(Integer)
      expect(subject.sent_invitations_count).to be_a(Integer)
      expect(subject.rate_of_no_show_for_invitations).to be_a(Float)
      expect(subject.rate_of_no_show_for_convocations).to be_a(Float)
      expect(subject.rate_of_no_show).to be_a(Float)
      expect(subject.average_time_between_invitation_and_rdv_in_days).to be_a(Float)
      expect(subject.rate_of_users_oriented_in_less_than_45_days).to be_a(Float)
      expect(subject.rate_of_users_accompanied_in_less_than_30_days).to be_a(Float)
      expect(subject.rate_of_users_oriented).to be_a(Float)
      expect(subject.rate_of_autonomous_users).to be_a(Float)
      expect(subject.agents_count).to be_a(Integer)
    end

    it "counts the users" do
      expect(stat).to receive(:all_users)
      expect(subject.users_count).to eq(2)
    end

    it "counts the users with rdv" do
      expect(stat).to receive(:user_ids_with_rdv_set)
      expect(subject.users_with_rdv_count).to eq(2)
    end

    it "counts the rdvs" do
      expect(stat).to receive(:all_participations)
      expect(subject.rdvs_count).to eq(2)
    end

    it "counts the sent invitations" do
      expect(stat).to receive(:invitations_set)
      expect(subject.sent_invitations_count).to eq(2)
    end

    it "computes the percentage of no show for invitations" do
      expect(stat).to receive(:participations_after_invitations_set)
      expect(Stats::ComputeRateOfNoShow).to receive(:call)
        .with(participations: [participation1])
      subject.rate_of_no_show_for_invitations
    end

    it "computes the percentage of no show for convocations" do
      expect(stat).to receive(:participations_with_notifications_set)
      expect(Stats::ComputeRateOfNoShow).to receive(:call)
        .with(participations: [participation2])
      subject.rate_of_no_show_for_convocations
    end

    it "computes the percentage of no show" do
      expect(stat).to receive(:participations_set)
      expect(Stats::ComputeRateOfNoShow).to receive(:call)
        .with(participations: [participation1, participation2])
      subject.rate_of_no_show
    end

    it "computes the average time between first invitation and first rdv in days" do
      expect(Stats::ComputeAverageTimeBetweenInvitationAndRdvInDays).to receive(:call)
        .with(structure: stat.statable)
      subject.average_time_between_invitation_and_rdv_in_days
    end

    it "computes the percentage of users with oriented follow up and rdv seen in less than 45 days" do
      expect(stat).to receive(:users_first_orientation_follow_up)
      expect(Stats::ComputeFollowUpSeenRateWithinDelays).to receive(:call)
        .with(follow_ups: [follow_up1, follow_up2], target_delay_days: 45)
      expect(subject.rate_of_users_oriented_in_less_than_45_days).to eq(50.0)
    end

    it "computes the percentage of users with accompanied follow up and rdv seen in less than 30 days" do
      expect(stat).to receive(:users_first_accompaniement_follow_up)
      expect(Stats::ComputeFollowUpSeenRateWithinDelays).to receive(:call)
        .with(follow_ups: [follow_up1, follow_up2], target_delay_days: 30, consider_orientation_rdv_as_start: true)
      expect(subject.rate_of_users_accompanied_in_less_than_30_days).to eq(25.0)
    end

    it "computes the percentage of users oriented" do
      expect(stat).to receive(:orientation_follow_ups_with_invitations)
      expect(Stats::ComputeRateOfUsersWithRdvSeen).to receive(:call)
        .with(follow_ups: [follow_up1, follow_up2])
      subject.rate_of_users_oriented
    end

    it "computes the percentage of invited users with at least on rdv taken in autonomy" do
      expect(stat).to receive(:invited_users_set)
      expect(Stats::ComputeRateOfAutonomousUsers).to receive(:call)
        .with(users: [user1, user2])
      subject.rate_of_autonomous_users
    end

    it "counts the agents" do
      expect(stat).to receive(:agents_set)
      expect(subject.agents_count).to eq(1)
    end
  end
end
