describe DepartmentPolicy, type: :policy do
  subject { described_class }

  let(:agent) { create(:agent) }
  let(:department) { create(:department) }

  describe "#show?" do
    context "when the agent belongs to the department" do
      let(:agent) { create(:agent, department: department) }

      permissions(:show?) { it { is_expected.to permit(agent, department) } }
    end

    context "when the agent does not belong to the department" do
      let(:other_department) { create(:department) }
      let(:agent) { create(:agent, department: other_department) }

      permissions(:show?) { it { is_expected.not_to permit(agent, department) } }
    end
  end
end
