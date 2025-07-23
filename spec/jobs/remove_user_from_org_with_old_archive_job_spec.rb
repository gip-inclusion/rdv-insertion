describe RemoveUserFromOrgWithOldArchiveJob do
  subject do
    described_class.new.perform(archive.id)
  end

  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation1, organisation2]) }
  let!(:organisation1) { create(:organisation, data_retention_duration_in_months: 24) }
  let!(:organisation2) { create(:organisation, data_retention_duration_in_months: 24) }
  let!(:archived_user) { create(:user, organisations: [organisation1, organisation2]) }
  let!(:archive) { create(:archive, user: archived_user, organisation: organisation1, created_at: 25.months.ago) }

  describe "#perform" do
    before do
      allow(RdvSolidaritesApi::DeleteUserProfile).to receive(:call)
        .with(
          rdv_solidarites_user_id: archived_user.rdv_solidarites_user_id,
          rdv_solidarites_organisation_id: organisation1.rdv_solidarites_organisation_id
        ).and_return(OpenStruct.new(success?: true))
    end

    context "when organisation has agents" do
      it "removes the user from the organisation" do
        subject
        expect(archived_user.reload.organisations).to eq([organisation2])
      end

      it "calls the delete user profile API" do
        expect(RdvSolidaritesApi::DeleteUserProfile).to receive(:call)
          .with(
            rdv_solidarites_user_id: archived_user.rdv_solidarites_user_id,
            rdv_solidarites_organisation_id: organisation1.rdv_solidarites_organisation_id
          )
        subject
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
