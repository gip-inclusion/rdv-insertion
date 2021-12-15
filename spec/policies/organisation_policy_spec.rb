describe OrganisationPolicy, type: :policy do
  subject { described_class }

  let(:agent) { create(:agent) }
  let(:organisation) { create(:organisation) }

  describe "#upload?" do
    context "when the agent belongs to the organisation" do
      let(:agent) { create(:agent, organisations: [organisation]) }

      permissions(:upload?) { it { is_expected.to permit(agent, organisation) } }
    end

    context "when the agent does not belong to the organisation" do
      let(:other_organisation) { create(:organisation) }
      let(:agent) { create(:agent, organisations: [other_organisation]) }

      permissions(:upload?) { it { is_expected.not_to permit(agent, organisation) } }
    end
  end
end
