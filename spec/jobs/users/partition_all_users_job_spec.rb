RSpec.describe Users::PartitionAllUsersJob do
  describe "#perform" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user) }

    before do
      user1.update_column(:department_id, nil)
      user3.update_column(:department_id, nil)
    end

    it "enqueues PartitionSingleUserJob for each user that has no department" do
      expect(Users::PartitionSingleUserJob).to receive(:perform_later).with(user1.id)
      expect(Users::PartitionSingleUserJob).not_to receive(:perform_later).with(user2.id)
      expect(Users::PartitionSingleUserJob).to receive(:perform_later).with(user3.id)

      described_class.new.perform
    end
  end
end
