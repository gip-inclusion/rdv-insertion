describe UserListUpload::CreateCreneauxSnapshotJob do
  subject { described_class.new.perform(user_list_upload_id) }

  let!(:user_list_upload) { create(:user_list_upload) }
  let(:user_list_upload_id) { user_list_upload.id }

  before do
    allow(UserListUpload::CreateCreneauxSnapshot).to receive(:call).and_return(OpenStruct.new(success?: true))
  end

  context "when the user list upload exists" do
    it "calls the create snapshot service and broadcasts a refresh" do
      expect_any_instance_of(UserListUpload).to receive(:broadcast_refresh)

      subject

      expect(UserListUpload::CreateCreneauxSnapshot).to have_received(:call).with(user_list_upload:)
    end
  end

  context "when the user list upload no longer exists" do
    before { user_list_upload.destroy }

    it "does nothing" do
      subject

      expect(UserListUpload::CreateCreneauxSnapshot).not_to have_received(:call)
    end
  end
end
