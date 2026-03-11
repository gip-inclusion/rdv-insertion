describe Users::PartitionSingleUserJob do
  subject { described_class.new.perform(user.id) }

  let!(:department1) { create(:department) }
  let!(:department2) { create(:department) }
  let!(:org1) { create(:organisation, department: department1) }
  let!(:org2) { create(:organisation, department: department2) }

  before do
    allow(SlackClient).to receive(:send_to_private_channel)
    allow(Users::RemoveFromOrganisation).to receive(:call)
      .and_return(OpenStruct.new(success?: true))
  end

  context "when the user has no department" do
    let!(:user) { create(:user, organisations: []) }

    it "does not assign a department_id" do
      expect { subject }.not_to(change { user.reload.department_id })
    end

    it "sends a slack warning mentioning the user id" do
      expect(SlackClient).to receive(:send_to_private_channel).with(include(user.id.to_s))
      subject
    end
  end

  context "when the user belongs to a single department" do
    let!(:user) do
      create(:user, organisations: [org1]).tap { |u| u.update_column(:department_id, nil) }
    end

    it "assigns the department_id" do
      expect { subject }.to change { user.reload.department_id }.to(department1.id)
    end

    it "does not call RemoveFromOrganisation" do
      expect(Users::RemoveFromOrganisation).not_to receive(:call)
      subject
    end
  end

  context "when the user belongs to multiple departments" do
    let!(:user) do
      create(:user, organisations: [org1]).tap { |u| u.update_column(:department_id, nil) }
    end

    before do
      # Bypass cross-department validation to simulate legacy data
      UsersOrganisation.new(user:, organisation: org2).tap { |uo| uo.save!(validate: false) }
      UsersOrganisation.where(user:, organisation: org2).update_all(created_at: 1.month.ago)
    end

    context "when there is no upcoming rdv in secondary orgs" do
      context "when the most recent activity is a users_organisation in department1" do
        before { UsersOrganisation.where(user:, organisation: org1).update_all(created_at: 2.days.ago) }

        it "assigns department1 as the department" do
          expect { subject }.to change { user.reload.department_id }.to(department1.id)
        end

        it "removes the user from the secondary organisation" do
          expect(Users::RemoveFromOrganisation).to receive(:call).with(user:, organisation: org2)
          subject
        end

        it "sends a slack notification mentioning the user id, department number and removed org id" do
          expect(SlackClient).to receive(:send_to_private_channel)
            .with(include(user.id.to_s, department1.number, org2.id.to_s))
          subject
        end
      end

      context "when the most recent activity is a participation in department2" do
        before do
          UsersOrganisation.where(user:).update_all(created_at: 1.month.ago)
          rdv = create(:rdv, organisation: org2)
          create(:participation, user:, rdv:, created_at: 1.day.ago)
        end

        it "assigns department2 as the department" do
          expect { subject }.to change { user.reload.department_id }.to(department2.id)
        end

        it "removes the user from the secondary organisation" do
          expect(Users::RemoveFromOrganisation).to receive(:call).with(user:, organisation: org1)
          subject
        end
      end

      context "when the most recent activity is an invitation in department1" do
        before do
          UsersOrganisation.where(user:).update_all(created_at: 1.month.ago)
          create(:invitation, user:, department: department1, created_at: 1.day.ago)
        end

        it "assigns department1 as the department" do
          expect { subject }.to change { user.reload.department_id }.to(department1.id)
        end
      end

      context "when RemoveFromOrganisation fails" do
        before do
          UsersOrganisation.where(user:, organisation: org1).update_all(created_at: 2.days.ago)
          allow(Users::RemoveFromOrganisation).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["some error"]))
        end

        it "raises an error" do
          expect { subject }.to raise_error(ApplicationJob::FailedServiceError)
        end

        it "does not assign a department_id" do
          expect do
            subject
          rescue StandardError
            nil
          end.not_to(change { user.reload.department_id })
        end
      end
    end

    context "when there is an upcoming rdv in a secondary org" do
      before do
        UsersOrganisation.where(user:, organisation: org1).update_all(created_at: 2.days.ago)
        rdv = create(:rdv, organisation: org2, starts_at: 1.week.from_now)
        create(:participation, user:, rdv:, created_at: 3.days.ago)
      end

      it "does not assign a department_id" do
        expect { subject }.not_to(change { user.reload.department_id })
      end

      it "does not call RemoveFromOrganisation" do
        expect(Users::RemoveFromOrganisation).not_to receive(:call)
        subject
      end

      it "sends a slack warning mentioning the user id and secondary org id" do
        expect(SlackClient).to receive(:send_to_private_channel)
          .with(include(user.id.to_s, org2.id.to_s))
        subject
      end
    end
  end
end
