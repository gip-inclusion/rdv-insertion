describe UsersOrganisation do
  describe "after_commit :delete_archive" do
    let(:user) { create(:user, organisations: [organisation]) }
    let(:organisation) { create(:organisation) }
    let(:archive) { create(:archive, organisation:, user:) }

    it "deletes the archive when the user is deleted" do
      perform_enqueued_jobs(only: DeleteArchiveJob) do
        user.organisations.delete(organisation)
      end
      expect(user.organisations.count).to eq(0)
      expect(Archive.find_by(organisation_id: organisation.id, user_id: user.id)).to be_nil
      expect(Archive.count).to eq(0)
    end
  end
end
