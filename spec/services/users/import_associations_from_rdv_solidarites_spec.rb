describe Users::ImportAssociationsFromRdvSolidarites, type: :service do
  subject do
    described_class.call(user:)
  end

  let(:user) { create(:user, organisations: [organisation], referents: []) }
  let(:organisation) { create(:organisation) }
  let(:other_organisation) { create(:organisation) }
  let(:referent) { create(:agent) }

  before do
    allow(RdvSolidaritesApi::RetrieveUserReferentAssignations).to receive(:call).and_return(
      OpenStruct.new(
        success?: true,
        referent_assignations: [OpenStruct.new(agent: OpenStruct.new(id: referent.rdv_solidarites_agent_id))]
      )
    )
    allow(RdvSolidaritesApi::RetrieveUser).to receive(:call).and_return(
      OpenStruct.new(
        success?: true,
        user: OpenStruct.new(
          organisation_ids: [
            organisation.rdv_solidarites_organisation_id,
            other_organisation.rdv_solidarites_organisation_id
          ]
        )
      )
    )
  end

  describe "#call" do
    it "is a success" do
      is_a_success
    end

    it "imports the associations" do
      subject
      expect(user.reload.referents).to eq([referent])
      expect(user.reload.organisations).to eq([organisation, other_organisation])
    end

    context "when the call to retrieve the user referent assignations fails" do
      before do
        allow(RdvSolidaritesApi::RetrieveUserReferentAssignations).to receive(:call).and_return(
          OpenStruct.new(success?: false)
        )
      end

      it "is a failure" do
        is_a_failure
      end
    end

    context "when the call to retrieve the user fails" do
      before do
        allow(RdvSolidaritesApi::RetrieveUser).to receive(:call).and_return(OpenStruct.new(success?: false))
      end

      it "is a failure" do
        is_a_failure
      end
    end
  end
end
