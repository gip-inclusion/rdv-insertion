RSpec.describe Users::PartitionSingleUserJob do
  describe "#perform" do
    let!(:department1) { create(:department) }
    let!(:department2) { create(:department) }
    let!(:organisation1) { create(:organisation, department: department1) }
    let!(:organisation2) { create(:organisation, department: department2) }
    let!(:user) { create(:user) }

    before do
      UsersOrganisation.new(user: user, organisation: organisation2).save!(validate: false)
      UsersOrganisation.new(user: user, organisation: organisation1).save!(validate: false)
    end

    context "when user has most recent activity in department1" do
      it "updates user department and removes other organisations" do
        described_class.new.perform(user.id)

        expect(user.reload.department).to eq(department1)
        expect(user.organisations).to contain_exactly(organisation1)
      end
    end

    context "when user has most recent activity in department2" do
      before do
        create(:participation, user: user, organisation: organisation2)
      end

      it "updates user department and removes other organisations" do
        described_class.new.perform(user.id)

        expect(user.reload.department).to eq(department2)
        expect(user.organisations).to contain_exactly(organisation2)
      end
    end

    context "when user has no activity" do
      it "keeps the most recently added organisation" do
        # Update the created_at of the users_organisations to simulate different addition times
        user.users_organisations.find_by(organisation: organisation1).update!(created_at: 2.days.ago)
        user.users_organisations.find_by(organisation: organisation2).update!(created_at: 1.day.ago)

        described_class.new.perform(user.id)

        expect(user.reload.department).to eq(department2)
        expect(user.organisations).to contain_exactly(organisation2)
      end
    end

    context "when user has activity across different types" do
      before do
        create(:participation, user: user, rdv: create(:rdv, organisation: organisation2))
        create(:invitation, user: user, organisations: [organisation1])
      end

      it "considers the most recent activity regardless of type" do
        described_class.new.perform(user.id)

        expect(user.reload.department).to eq(department1)
        expect(user.organisations).to contain_exactly(organisation1)
      end
    end

    context "when user has no organisations" do
      before do
        user.users_organisations.destroy_all
      end

      it "does not update the department" do
        original_department = user.department
        described_class.new.perform(user.id)

        expect(user.reload.department).to eq(original_department)
      end
    end

    context "when user has multiple organisations in the same department as the most recent active one" do
      let!(:organisation3) { create(:organisation, department: department2) }

      before do
        UsersOrganisation.new(user: user, organisation: organisation3).save!(validate: false)
        create(:participation, user: user, organisation: organisation2)
      end

      it "preserves all organisations in the same department and removes others" do
        described_class.new.perform(user.id)

        expect(user.reload.department).to eq(department2)
        expect(user.organisations).to contain_exactly(organisation2, organisation3)
        expect(user.organisations).not_to include(organisation1)
      end
    end
  end
end
