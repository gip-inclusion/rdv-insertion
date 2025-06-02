describe RemoveOrganisationUserForExpiredArchiveJob do
  subject do
    described_class.new.perform(archive.id)
  end

  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation1, organisation2]) }
  let!(:organisation1) { create(:organisation, department:) }
  let!(:organisation2) { create(:organisation, department:) }
  let!(:department) { create(:department) }
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

    it "remove the user from organisation1 after 2 years of archiving" do
      subject
      expect(archived_user.reload.organisations).to eq([organisation2])
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
