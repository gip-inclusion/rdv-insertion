describe DepartmentPolicy, type: :policy do
  subject { described_class }

  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:department) { create(:department) }

  describe "#upload?" do
    context "when the agent belongs to all the department the organisations" do
      permissions(:upload?) { it { is_expected.to permit(agent, department) } }
    end

    context "when the agent does not belong to all the department organisations" do
      let!(:other_organisation) { create(:organisation, department: department) }

      permissions(:upload?) { it { is_expected.not_to permit(agent, department) } }
    end
  end
end
