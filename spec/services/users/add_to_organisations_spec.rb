describe Users::AddToOrganisations, type: :service do
  subject do
    described_class.call(organisations: [organisation], user:)
  end

  let!(:organisation) { create(:organisation, department:) }
  let!(:user) { create(:user, department:) }
  let!(:department) { create(:department) }

  describe "#call" do
    before do
      allow(RdvSolidaritesApi::CreateUserProfiles).to receive(:call)
        .with(
          rdv_solidarites_user_id: user.rdv_solidarites_user_id,
          rdv_solidarites_organisation_ids: [organisation.rdv_solidarites_organisation_id]
        ).and_return(OpenStruct.new(success?: true))
    end

    it "is a success" do
      is_a_success
    end

    it "adds the user to the organisation" do
      subject
      expect(user.reload.organisations).to include(organisation)
    end

    it "is idempotent" do
      2.times { described_class.call(organisations: [organisation], user:) }
      expect(user.reload.organisations).to include(organisation)
      expect(user.reload.organisations.size).to eq(1)
    end

    context "when it fails it remove the added org" do
      before do
        allow(RdvSolidaritesApi::CreateUserProfiles).to receive(:call)
          .with(
            rdv_solidarites_user_id: user.rdv_solidarites_user_id,
            rdv_solidarites_organisation_ids: [organisation.rdv_solidarites_organisation_id]
          ).and_return(OpenStruct.new(success?: false, errors: ["impossible to create"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "does not add the user to the organisation" do
        subject
        expect(user.reload.organisations).not_to include(organisation)
      end

      it "outputs an error" do
        expect(subject.errors).to eq(["impossible to create"])
      end
    end
  end
end
