describe UserPolicy, type: :policy do
  subject { described_class }

  let!(:organisation) { create(:organisation) }
  let!(:organisation2) { create(:organisation) }
  let!(:agent) { create(:agent, organisations: [organisation]) }

  describe "#show?" do
    context "when the agent belongs to a department organisation" do
      let!(:user) { create(:user, organisations: [organisation, organisation2]) }

      permissions(:show?) { it { is_expected.to permit(agent, user) } }
    end

    context "when the agent does not belong to all the department organisations" do
      let!(:user) { create(:user, organisations: [organisation2]) }

      permissions(:show?) { it { is_expected.not_to permit(agent, user) } }
    end

    context "when the user is deleted" do
      let!(:user) { create(:user, organisations: [organisation], deleted_at: 2.days.ago) }

      permissions(:show?) { it { is_expected.not_to permit(agent, user) } }
    end
  end
end
