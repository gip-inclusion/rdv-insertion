describe RemoveOrganisationUsersForExpiredArchivesJob do
  subject { described_class.new.perform }

  let!(:org1) { create(:organisation, data_retention_duration: 24) }
  let!(:org2) { create(:organisation, data_retention_duration: 36) }

  describe "#perform" do
    context "with expired archives according to organization retention" do
      let!(:old_archive_org1) { create(:archive, organisation: org1, created_at: 25.months.ago) }
      let!(:recent_archive_org2) { create(:archive, organisation: org2, created_at: 2.years.ago) }

      it "schedules cleanup jobs for expired archives according to each organization's retention" do
        expect(RemoveOrganisationUserForExpiredArchiveJob).to receive(:perform_later).with(old_archive_org1.id)
        expect(RemoveOrganisationUserForExpiredArchiveJob).not_to receive(:perform_later).with(recent_archive_org2.id)

        subject
      end

      it "sends mattermost notification with correct count" do
        expect(MattermostClient).to receive(:send_to_notif_channel)
          .with(/1 usagers archivés ont été retirés de leurs organisations/)

        subject
      end
    end

    context "with expired archives but users with recent RDVs" do
      let!(:user_with_recent_rdv) { create(:user) }
      let!(:user_without_recent_rdv) { create(:user) }
      let!(:expired_archive_with_recent_rdv) do
        create(:archive, organisation: org1, user: user_with_recent_rdv, created_at: 25.months.ago)
      end
      let!(:expired_archive_without_recent_rdv) do
        create(:archive, organisation: org1, user: user_without_recent_rdv, created_at: 25.months.ago)
      end
      let!(:recent_rdv) do
        create(:rdv, organisation: org1, participations: [build(:participation, user: user_with_recent_rdv)])
      end

      it "only schedules cleanup jobs for users without recent RDVs" do
        expect(RemoveOrganisationUserForExpiredArchiveJob).not_to receive(:perform_later)
          .with(expired_archive_with_recent_rdv.id)
        expect(RemoveOrganisationUserForExpiredArchiveJob).to receive(:perform_later)
          .with(expired_archive_without_recent_rdv.id)

        subject
      end
    end

    context "with no expired archives" do
      let!(:recent_archive) { create(:archive, organisation: org1, created_at: 1.month.ago) }

      it "does not schedule any cleanup jobs" do
        expect(RemoveOrganisationUserForExpiredArchiveJob).not_to receive(:perform_later)
        subject
      end

      it "does not send mattermost notification" do
        expect(MattermostClient).not_to receive(:send_to_notif_channel)
        subject
      end
    end
  end
end
