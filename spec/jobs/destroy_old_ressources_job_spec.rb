describe DestroyOldRessourcesJob do
  subject do
    described_class.new.perform
  end

  let!(:organisation) { create(:organisation) }
  let!(:recent_user) { create(:user, department: organisation.department, organisations: [organisation]) }
  let!(:recent_rdv_collectif_with_no_participation) do
    create(:rdv, participations: [], created_at: 25.months.ago)
  end

  let!(:inactive_user_created_25_months_ago) { create(:user, created_at: 26.months.ago, department: organisation.department) }
  let!(:users_organisation1) do
    create(:users_organisation, user: inactive_user_created_25_months_ago,
                                organisation: organisation, created_at: 25.months.ago)
  end
  let!(:invitation1) do
    create(:invitation, user: inactive_user_created_25_months_ago,
                        organisations: [organisation], created_at: 25.months.ago)
  end
  let!(:participation1) do
    create(:participation, user: inactive_user_created_25_months_ago,
                           organisation: organisation, created_at: 25.months.ago)
  end
  let!(:rdv1) do
    create(:rdv, participations: [participation1], created_at: 25.months.ago)
  end
  let!(:nullified_old_notification) do
    create(
      :notification,
      participation: participation1, event: "participation_created", format: "sms",
      created_at: 25.months.ago
    )
  end

  let!(:user_created_25_months_ago_with_a_recent_invitation) { create(:user, created_at: 25.months.ago, department: organisation.department) }
  let!(:users_organisation2) do
    create(:users_organisation, user: user_created_25_months_ago_with_a_recent_invitation,
                                organisation: organisation, created_at: 25.months.ago)
  end
  let!(:invitation2) do
    create(:invitation, user: user_created_25_months_ago_with_a_recent_invitation, created_at: 1.month.ago)
  end
  let!(:participation2) do
    create(:participation, user: user_created_25_months_ago_with_a_recent_invitation, created_at: 25.months.ago)
  end
  let!(:rdv2) do
    create(:rdv, participations: [participation2], created_at: 1.month.ago)
  end
  let!(:old_notification_with_participation_id) do
    create(
      :notification,
      participation: participation2, event: "participation_created", format: "sms",
      created_at: 25.months.ago
    )
  end

  let!(:user_created_25_months_ago_with_recent_and_old_records) { create(:user, created_at: 25.months.ago, department: organisation.department) }
  let!(:users_organisation3) do
    create(:users_organisation, user: user_created_25_months_ago_with_recent_and_old_records,
                                organisation: organisation, created_at: 25.months.ago)
  end
  let!(:invitation3) do
    create(:invitation, user: user_created_25_months_ago_with_recent_and_old_records, created_at: 25.months.ago)
  end
  let!(:participation3) do
    create(:participation, user: user_created_25_months_ago_with_recent_and_old_records, created_at: 1.month.ago)
  end
  let!(:invitation4) do
    create(:invitation, user: user_created_25_months_ago_with_recent_and_old_records, created_at: 1.month.ago)
  end
  let!(:participation4) do
    create(:participation, user: user_created_25_months_ago_with_recent_and_old_records, created_at: 25.months.ago)
  end
  let!(:recent_notification) do
    create(
      :notification,
      participation: participation4, event: "participation_created", format: "sms", created_at: 1.month.ago
    )
  end

  let!(:user_created_25_months_ago_with_a_recent_organisation) { create(:user, created_at: 25.months.ago, department: organisation.department) }
  let!(:users_organisation4) do
    create(:users_organisation, user: user_created_25_months_ago_with_a_recent_organisation,
                                organisation: organisation, created_at: 1.month.ago)
  end
  let!(:invitation5) do
    create(:invitation, user: user_created_25_months_ago_with_a_recent_organisation, created_at: 25.months.ago)
  end
  let!(:participation5) do
    create(:participation, user: user_created_25_months_ago_with_a_recent_organisation, created_at: 25.months.ago)
  end

  describe "#perform" do
    it "destroys the inactive user" do
      subject
      expect(User.all).to include(recent_user)
      expect(User.all).to include(user_created_25_months_ago_with_a_recent_invitation)
      expect(User.all).to include(user_created_25_months_ago_with_recent_and_old_records)
      expect(User.all).to include(user_created_25_months_ago_with_a_recent_organisation)
      expect(User.all).not_to include(inactive_user_created_25_months_ago)
    end

    it "destroys the useless rdvs" do
      subject
      expect(Rdv.all).to include(recent_rdv_collectif_with_no_participation)
      expect(Rdv.all).not_to include(rdv1)
      expect(Rdv.all).to include(rdv2)
    end

    it "destroys the useless notifications" do
      subject
      expect(Notification.all).to include(recent_notification)
      expect(Notification.all).to include(old_notification_with_participation_id)
      expect(Notification.all).not_to include(nullified_old_notification)
    end
  end
end
