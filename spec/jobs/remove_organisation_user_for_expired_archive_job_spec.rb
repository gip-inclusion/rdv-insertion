describe RemoveOrganisationUserForExpiredArchiveJob do
  subject do
    described_class.new.perform(archive.id)
  end

  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation1, organisation2]) }
  let!(:organisation1) { create(:organisation, data_retention_duration: 24) }
  let!(:organisation2) { create(:organisation, data_retention_duration: 24) }
  let!(:archived_user) { create(:user, organisations: [organisation1, organisation2]) }
  let!(:archive) { create(:archive, user: archived_user, organisation: organisation1, created_at: 25.months.ago) }

  describe "#perform" do
    context "will remove the user from the organisation" do
      before do
        allow(RdvSolidaritesApi::DeleteUserProfile).to receive(:call)
          .with(
            rdv_solidarites_user_id: archived_user.rdv_solidarites_user_id,
            rdv_solidarites_organisation_id: organisation1.rdv_solidarites_organisation_id
          ).and_return(OpenStruct.new(success?: true))
      end

      context "when user has no recent activity in the organisation" do
        it "removes the user from organisation1 after expired archive period" do
          subject
          expect(archived_user.reload.organisations).to eq([organisation2])
        end
      end

      context "with recent activity in other organisation only" do
        let!(:recent_rdv_other_org) do
          create(:rdv,
                 organisation: organisation2,
                 participations: [build(:participation, user: archived_user)],
                 created_at: 1.month.ago)
        end

        it "still removes the user from organisation1 (activity in other organisation should not prevent removal)" do
          subject
          expect(archived_user.reload.organisations).to eq([organisation2])
        end
      end
    end

    context "when user has recent activity in the organisation" do
      context "with recent participation in the organisation" do
        let!(:recent_participation) do
          rdv = create(:rdv, organisation: organisation1)
          create(:participation, user: archived_user, rdv: rdv, created_at: 1.month.ago)
        end

        it "does not remove the user from the organisation" do
          subject
          expect(archived_user.reload.organisations).to contain_exactly(organisation1, organisation2)
        end
      end

      context "with recent invitation for the organisation" do
        let!(:recent_invitation) do
          create(:invitation, user: archived_user, organisations: [organisation1], created_at: 1.month.ago)
        end

        it "does not remove the user from the organisation" do
          subject
          expect(archived_user.reload.organisations).to contain_exactly(organisation1, organisation2)
        end
      end

      context "with recent tag assignment for tags in the organisation" do
        let!(:tag) { create(:tag, organisations: [organisation1]) }
        let!(:recent_tag_user) { create(:tag_user, user: archived_user, tag: tag, created_at: 1.month.ago) }

        it "does not remove the user from the organisation" do
          subject
          expect(archived_user.reload.organisations).to contain_exactly(organisation1, organisation2)
        end
      end

      context "with recent referent assignation with agent from the organisation" do
        let!(:recent_referent_assignation) do
          create(:referent_assignation, user: archived_user, agent: agent, created_at: 1.month.ago)
        end

        it "does not remove the user from the organisation" do
          subject
          expect(archived_user.reload.organisations).to contain_exactly(organisation1, organisation2)
        end
      end
    end

    context "when no agent found" do
      before do
        organisation1.agents.destroy_all
      end

      it "logs a message" do
        expect(Sentry).to receive(:capture_message)
          .with("No agent found for organisation #{organisation1.id} when trying to remove user #{archived_user.id}")
        subject
      end
    end
  end
end
