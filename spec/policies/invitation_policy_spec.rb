describe InvitationPolicy, type: :policy do
  subject { described_class }

  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department:) }
  let!(:organisation2) { create(:organisation, department:) }
  let!(:invitation) { create(:invitation, user: user) }
  let!(:agent) { create(:agent, organisations: [organisation]) }

  describe "#create?" do
    let!(:user) { create(:user, organisations: [organisation, organisation2]) }

    context "when the agent belongs to the user organisation" do
      permissions(:create?) { it { is_expected.to permit(agent, invitation) } }
    end

    context "when the agent does not belong to the user organisation" do
      let!(:user) { create(:user, organisations: [organisation2]) }

      permissions(:create?) { it { is_expected.not_to permit(agent, invitation) } }
    end
  end
end
