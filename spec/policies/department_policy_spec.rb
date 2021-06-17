describe DepartmentPolicy, type: :policy do
  let(:agent) { create(:agent) }
  let(:department) { create(:department) }
  subject { described_class }

  describe "#show?" do
    context "when the agent belongs to the department" do
      let(:agent) { create(:agent, department: department) }
      permissions(:show?) { it { is_expected.to permit(agent, department) } }
    end

    context "when the agent does not belong to the department" do
      let(:other_department) { create(:department) }
      let(:agent) { create(:agent, department: other_department) }
      permissions(:show?) { it { is_expected.to_not permit(agent, department) } }
    end
  end
end
