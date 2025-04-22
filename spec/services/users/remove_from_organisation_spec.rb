describe Users::RemoveFromOrganisation, type: :service do
  subject do
    described_class.call(organisation:, user:)
  end

  let!(:organisation) { create(:organisation) }
  let!(:user) { create(:user, organisations: [organisation]) }

  describe "#call" do
    before do
      allow(RdvSolidaritesApi::DeleteUserProfile).to receive(:call)
        .with(
          rdv_solidarites_user_id: user.rdv_solidarites_user_id,
          rdv_solidarites_organisation_id: organisation.rdv_solidarites_organisation_id
        ).and_return(OpenStruct.new(success?: true))
    end

    it "is a success" do
      is_a_success
    end

    it "removes the user from the organisation" do
      subject
      expect(user.reload.organisations).not_to include(organisation)
    end

    it "deletes the user when there is no org attached" do
      subject
      expect(user.deleted?).to eq(true)
      expect(user.first_name).to eq("Usager supprimé")
      expect(user.last_name).to eq("Usager supprimé")
    end

    context "when user does not have a rdv_solidarites_user_id" do
      before do
        user.update!(rdv_solidarites_user_id: nil)
      end

      it "remove the user from organisation but does not call rdvs api" do
        expect(RdvSolidaritesApi::DeleteUserProfile).not_to receive(:call)
        subject
        expect(user.reload.organisations).not_to include(organisation)
      end
    end

    context "when the user is attached to more than one org" do
      let!(:other_organisation) { create(:organisation) }
      let!(:user) { create(:user, organisations: [organisation, other_organisation]) }

      it "does not delete the user" do
        subject
        expect(user.deleted?).to eq(false)
      end
    end

    context "when it fails to remove the org through API" do
      before do
        allow(RdvSolidaritesApi::DeleteUserProfile).to receive(:call)
          .with(
            rdv_solidarites_user_id: user.rdv_solidarites_user_id,
            rdv_solidarites_organisation_id: organisation.rdv_solidarites_organisation_id
          ).and_return(OpenStruct.new(success?: false, errors: ["impossible to remove"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "does not remove the user from the organisation" do
        subject
        expect(user.reload.organisations).to include(organisation)
      end

      it "outputs an error" do
        expect(subject.errors).to eq(["impossible to remove"])
      end
    end
  end
end
