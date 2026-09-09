describe InvalidateInvitationsAfterArchivingJob do
  subject(:perform_job) { described_class.new.perform(archive.id) }

  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department:) }
  let!(:other_organisation) { create(:organisation, department:) }
  let!(:user) { create(:user, organisations: [organisation, other_organisation]) }
  let!(:archive) { create(:archive, user:, organisation:) }

  let!(:invitation) do
    create(:invitation, user:, department:, organisations: [organisation, other_organisation])
  end

  context "when the user is archived in every organisation shared with the invitation" do
    before { create(:archive, user:, organisation: other_organisation, archiving_reason: "test") }

    it "expires the invitation" do
      expect(ExpireInvitationJob).to receive(:perform_later).with(invitation.id)
      perform_job
    end
  end

  context "when the user is still active in one of the invitation's organisations" do
    it "does not expire the invitation" do
      expect(ExpireInvitationJob).not_to receive(:perform_later).with(invitation.id)
      perform_job
    end
  end

  context "when the invitation targets an organisation the user does not belong to" do
    let!(:foreign_organisation) { create(:organisation, department:) }
    let!(:invitation) do
      create(:invitation, user:, department:, organisations: [organisation, foreign_organisation])
    end

    it "ignores that organisation and expires the invitation" do
      expect(ExpireInvitationJob).to receive(:perform_later).with(invitation.id)
      perform_job
    end
  end
end
