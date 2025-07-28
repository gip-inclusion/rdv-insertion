describe Organisation::UsersRetriever, type: :model do
  let(:organisation) { create(:organisation, data_retention_duration_in_months: 24) }
  let(:retriever) { described_class.new(organisation: organisation) }
  let(:old_date) { 25.months.ago }
  let(:recent_date) { 1.month.ago }
  let!(:inactive_user) { create(:user) }
  let!(:active_user) { create(:user) }
  let!(:inactive_user_organisation) do
    create(:users_organisation, user: inactive_user, organisation: organisation, created_at: old_date)
  end
  let!(:active_user_organisation) do
    create(:users_organisation, user: active_user, organisation: organisation, created_at: recent_date)
  end

  describe "#inactive_users" do
    context "when user has no recent activity" do
      it "includes the user in inactive users" do
        expect(retriever.inactive_users).to contain_exactly(inactive_user)
      end
    end

    context "when user has recent invitation" do
      let!(:recent_invitation) do
        create(:invitation, user: inactive_user, organisations: [organisation], created_at: recent_date)
      end

      it "excludes the user from inactive users" do
        expect(retriever.inactive_users).to eq([])
      end
    end

    context "when user has recent participation" do
      let!(:recent_participation) do
        rdv = create(:rdv, organisation: organisation)
        create(:participation, user: inactive_user, rdv: rdv, created_at: recent_date)
      end

      it "excludes the user from inactive users" do
        expect(retriever.inactive_users).to eq([])
      end
    end

    context "when user has recent tag assignment" do
      let!(:tag) { create(:tag, organisations: [organisation]) }
      let!(:recent_tag_user) { create(:tag_user, user: inactive_user, tag: tag, created_at: recent_date) }

      it "excludes the user from inactive users" do
        expect(retriever.inactive_users).to eq([])
      end
    end

    context "when user has recent referent assignation" do
      let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }
      let!(:recent_referent_assignation) do
        create(:referent_assignation, user: inactive_user, agent: agent, created_at: recent_date)
      end

      it "excludes the user from inactive users" do
        expect(retriever.inactive_users).to eq([])
      end
    end

    context "when user has recent activity in other organisation only" do
      let!(:other_organisation) { create(:organisation, data_retention_duration_in_months: 24) }

      context "with recent invitation in other organisation" do
        let!(:recent_invitation_other_org) do
          create(:invitation, user: inactive_user, organisations: [other_organisation], created_at: recent_date)
        end

        it "still includes the user in inactive users" do
          expect(retriever.inactive_users).to contain_exactly(inactive_user)
        end
      end

      context "with recent participation in other organisation" do
        let!(:recent_participation_other_org) do
          rdv = create(:rdv, organisation: other_organisation)
          create(:participation, user: inactive_user, rdv: rdv, created_at: recent_date)
        end

        it "still includes the user in inactive users" do
          expect(retriever.inactive_users).to contain_exactly(inactive_user)
        end
      end

      context "with recent tag assignment in other organisation" do
        let!(:tag_other_org) { create(:tag, organisations: [other_organisation]) }
        let!(:recent_tag_user_other_org) do
          create(:tag_user, user: inactive_user, tag: tag_other_org, created_at: recent_date)
        end

        it "still includes the user in inactive users" do
          expect(retriever.inactive_users).to contain_exactly(inactive_user)
        end
      end

      context "with recent referent assignation in other organisation" do
        let!(:agent_other_org) { create(:agent, admin_role_in_organisations: [other_organisation]) }
        let!(:recent_referent_assignation_other_org) do
          create(:referent_assignation, user: inactive_user, agent: agent_other_org, created_at: recent_date)
        end

        it "still includes the user in inactive users" do
          expect(retriever.inactive_users).to contain_exactly(inactive_user)
        end
      end
    end

    context "when the user has been updated recently" do
      before do
        inactive_user.update!(first_name: "John", last_name: "Doe")
      end

      it "excludes the user from inactive users" do
        expect(retriever.inactive_users).to eq([])
      end
    end
  end
end
