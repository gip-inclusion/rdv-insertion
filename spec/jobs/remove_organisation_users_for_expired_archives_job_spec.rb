describe RemoveOrganisationUsersForExpiredArchivesJob do
  subject do
    described_class.new.perform
  end

  let!(:department) { create(:department) }
  let!(:agent) { create(:agent, admin_role_in_organisations: organisations) }
  let!(:organisation1) { create(:organisation, department: department) }
  let!(:organisation2) { create(:organisation, department: department) }
  let!(:organisation3) { create(:organisation, department: department) }
  let!(:organisation4) { create(:organisation, department: department) }
  let!(:organisations) { [organisation1, organisation2, organisation3, organisation4] }
  let!(:archived_user) { create(:user, organisations: organisations) }
  let!(:old_archive1) { create(:archive, user: archived_user, organisation: organisation1, created_at: 25.months.ago) }
  let!(:old_archive2) { create(:archive, user: archived_user, organisation: organisation2, created_at: 26.months.ago) }
  let!(:archive3) { create(:archive, user: archived_user, organisation: organisation3, created_at: 1.month.ago) }
  let!(:archive4) { create(:archive, user: archived_user, organisation: organisation4) }

  describe "#perform" do
    it "enqueues remove organisation job for each expired archive" do
      expect(RemoveOrganisationUserForExpiredArchiveJob).to receive(:perform_later)
        .with(old_archive1.id)
      expect(RemoveOrganisationUserForExpiredArchiveJob).to receive(:perform_later)
        .with(old_archive2.id)
      expect(MattermostClient).to receive(:send_to_notif_channel).with(
        "🧹 2 usagers archivés il y a plus de 2 ans ont été retirés de leurs organisations"
      )
      subject
    end
  end
end
