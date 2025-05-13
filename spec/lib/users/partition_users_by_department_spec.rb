require Rails.root.join("lib/users/partition_users_by_department")

RSpec.describe Users::PartitionUsersByDepartment do
  describe "#call" do
    let!(:department1) { create(:department) }
    let!(:department2) { create(:department) }
    let!(:organisation1) { create(:organisation, department: department1, name: "Organisation 1") }
    let!(:organisation2) { create(:organisation, department: department2, name: "Organisation 2") }
    let!(:user) { create(:user, department: department1) }

    before do
      UsersOrganisation.new(user: user, organisation: organisation1).save!(validate: false)
      UsersOrganisation.new(user: user, organisation: organisation2).save!(validate: false)
    end

    context "when user has most recent activity in department1" do
      before do
        create(:participation, user: user, organisation: organisation2)
        create(:participation, user: user, organisation: organisation1)
      end

      it "removes user from department2 and updates user department" do
        described_class.new.call

        expect(user.reload.department).to eq(department1)
        expect(user.users_organisations.count).to eq(1)
        expect(user.users_organisations.first.organisation).to eq(organisation1)
      end
    end

    context "when user has most recent activity in department2" do
      before do
        create(:participation, user: user, organisation: organisation1)
        create(:participation, user: user, organisation: organisation2)
      end

      it "removes user from department1 and updates user department" do
        described_class.new.call

        expect(user.reload.department).to eq(department2)
        expect(user.users_organisations.count).to eq(1)
        expect(user.users_organisations.first.organisation).to eq(organisation2)
      end
    end

    context "when user has no activity" do
      it "keeps the most recently added organisation" do
        # Update the created_at of the users_organisations to simulate different addition times
        user.users_organisations.find_by(organisation: organisation1).update!(created_at: 2.days.ago)
        user.users_organisations.find_by(organisation: organisation2).update!(created_at: 1.day.ago)

        described_class.new.call

        expect(user.reload.department).to eq(department2)
        expect(user.users_organisations.count).to eq(1)
        expect(user.users_organisations.first.organisation).to eq(organisation2)
      end
    end

    context "when user has activity across different types" do
      before do
        create(:participation, user: user, rdv: create(:rdv, organisation: organisation2))
        create(:invitation, user: user, organisations: [organisation1])
      end

      it "considers the most recent activity regardless of type" do
        described_class.new.call

        expect(user.reload.department).to eq(department1)
        expect(user.users_organisations.count).to eq(1)
        expect(user.users_organisations.first.organisation).to eq(organisation1)
      end
    end
  end
end
