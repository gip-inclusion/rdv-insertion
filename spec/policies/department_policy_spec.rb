describe DepartmentPolicy, type: :policy do
  subject { described_class }

  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:department) { create(:department) }

  describe "#access?" do
    context "when the agent belongs to onee of the department organisations" do
      permissions(:access?) { it { is_expected.to permit(agent, department) } }
    end

    context "when the agent does not belong to all the department organisations" do
      let!(:other_department) { create(:department) }
      let!(:organisation) { create(:organisation, department: other_department) }

      permissions(:access?) { it { is_expected.not_to permit(agent, department) } }
    end
  end
end
