require "rails_helper"

RSpec.describe Users::PartitionAllUsersJob do
  describe "#perform" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user) }

    it "enqueues PartitionSingleUserJob for each user" do
      expect(Users::PartitionSingleUserJob).to receive(:perform_later).with(user1.id)
      expect(Users::PartitionSingleUserJob).to receive(:perform_later).with(user2.id)
      expect(Users::PartitionSingleUserJob).to receive(:perform_later).with(user3.id)

      described_class.new.perform
    end
  end
end
